#!/usr/bin/env bash
source scripts/common.sh
ALT="192.168.0.21"; ASTRA="192.168.0.22"; REDOS="192.168.0.23"

ok=true

# 1. Astra → memcached
if run "$ASTRA" "printf 'stats\nquit\n' | nc -w1 memcached.local 11211"; then
  echo "[✓] Astra → memcached OK";
else
  echo "[✗] Ошибка доступа Astra → memcached"; ok=false;
fi

# 2. RedOS → memcached (должен быть блок)
if run "$REDOS" "nc -z -w1 $ALT 11211"; then
  echo "[✗] RedOS смог подключиться к memcached!"; ok=false;
else
  echo "[✓] RedOS заблокирован";
fi

# 3. Трассировки на 8.8.8.8
for h in $ALT $ASTRA; do
  hop=$(run "$h" "ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if(\$i==\"via\"){print \$(i+1); exit}}'")
  [[ "$hop" == "$REDOS" ]] && echo "[✓] $h выходит через RedOS" || { echo "[✗] $h не через RedOS"; ok=false; }
done

$ok && echo -e "\n🎉 Итог: УСПЕХ" || echo -e "\n⚠️ Итог: ЕСТЬ ОШИБКИ"
