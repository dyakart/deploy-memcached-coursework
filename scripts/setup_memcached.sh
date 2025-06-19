#!/usr/bin/env bash
# Установка memcached на Alt (192.168.0.21)
source "$(dirname "$0")/common.sh"
ALT="192.168.0.21"
ASTRA="192.168.0.22"

# 1. Устанавливаем пакет
run "$ALT" "command -v memcached || (apt-get -yq install memcached || yum -y install memcached)"

# 2. Обновляем конфиг так, чтобы memcached слушал на 0.0.0.0
run "$ALT" "if [ -f /etc/sysconfig/memcached ]; then
               sed -i 's/^OPTIONS=.*/OPTIONS=\"-l 0.0.0.0 -m 64\"/' /etc/sysconfig/memcached; fi"
run "$ALT" "if [ -f /etc/memcached.conf ]; then
               sed -i 's/^-l .*/-l 0.0.0.0/' /etc/memcached.conf; fi"

# 3. Перезапускаем сервис, чтобы подтянулся новый конфиг
run "$ALT" "systemctl daemon-reload && systemctl enable --now memcached"
