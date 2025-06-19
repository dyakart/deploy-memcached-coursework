#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

./scripts/setup_router.sh

# Меняем default‑gateway на Alt и Astra
SSH_USER="root"
for h in 192.168.0.21 192.168.0.22; do
  ssh -o StrictHostKeyChecking=no "$SSH_USER@$h" "ip route replace default via 192.168.0.23"
done

./scripts/setup_memcached.sh
./scripts/setup_astra.sh

echo -e "\n✅ Развёртывание завершено. Запустите ./verify.sh для тестов."
