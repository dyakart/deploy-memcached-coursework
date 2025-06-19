#!/usr/bin/env bash
# Настройка Astra (192.168.0.22)
source "$(dirname "$0")/common.sh"
ASTRA="192.168.0.22"
ALT="192.168.0.21"
REDOS="192.168.0.23"

# 1. hosts → memcached.local
ensure_line "$ASTRA" /etc/hosts "${ALT}    memcached.local"

# 2. Блокируем RedOS → memcached
iptables_add "$ASTRA" filter "OUTPUT -p tcp --dport 11211 -d $ALT -s $REDOS -j REJECT"
