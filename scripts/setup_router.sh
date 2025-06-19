#!/usr/bin/env bash
# Настройка RedOS (192.168.0.23) как маршрутизатора
source "$(dirname "$0")/common.sh"
ROUTER="192.168.0.23"
EXT_IF="eth1"

# 1. Включаем IP‑forwarding
ensure_line "$ROUTER" /etc/sysctl.d/99-router.conf "net.ipv4.ip_forward=1"
run "$ROUTER" "sysctl -p /etc/sysctl.d/99-router.conf"

# 2. NAT
iptables_add "$ROUTER" nat "POSTROUTING -o $EXT_IF -j MASQUERADE"

# 3. Сохраняем iptables
run "$ROUTER" "service iptables save || iptables-save > /etc/iptables.rules"
