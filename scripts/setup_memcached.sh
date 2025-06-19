#!/usr/bin/env bash
# Установка memcached на Alt (192.168.0.21)
source "$(dirname "$0")/common.sh"
ALT="192.168.0.21"
ASTRA="192.168.0.22"

# 1. Установка пакета
run "$ALT" "command -v memcached || (apt-get -yq install memcached || yum -y install memcached)"

# 2. Гарантируем прослушивание на всех интерфейсах
run "$ALT" "sed -i -e 's/^LISTEN=.*/LISTEN=\"0.0.0.0\"/' \
                   -e 's/^OPTIONS=.*/OPTIONS=\"-l 0.0.0.0 -m 64\"/' \
                   /etc/sysconfig/memcached 2>/dev/null || true"
run "$ALT" "grep -q '^LISTEN=' /etc/sysconfig/memcached || echo 'LISTEN=\"0.0.0.0\"' >> /etc/sysconfig/memcached"
run "$ALT" "[ -f /etc/memcached.conf ] && sed -i 's/^-l .*/-l 0.0.0.0/' /etc/memcached.conf || true"
run "$ALT" "systemctl daemon-reload && systemctl restart memcached"

# 3. iptables: allow only Astra
iptables_add "$ALT" filter "INPUT -p tcp --dport 11211 -s $ASTRA -j ACCEPT"
iptables_add "$ALT" filter "INPUT -p tcp --dport 11211 -j DROP"
