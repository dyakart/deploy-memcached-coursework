#!/usr/bin/env bash
# Установка memcached на Alt (192.168.0.21)
source "$(dirname "$0")/common.sh"
ALT="192.168.0.21"
ASTRA="192.168.0.22"

# 1. Устанавливаем пакет
run "$ALT" "command -v memcached || (apt-get -yq install memcached || yum -y install memcached)"

# 2. Разрешаем прослушивание на всех интерфейсах
CONF="/etc/memcached.conf"
ensure_line "$ALT" "$CONF" "-l 0.0.0.0"
run "$ALT" "systemctl enable --now memcached"

# 3. iptables: allow only Astra
iptables_add "$ALT" filter "INPUT -p tcp --dport 11211 -s $ASTRA -j ACCEPT"
iptables_add "$ALT" filter "INPUT -p tcp --dport 11211 -j DROP"
