#!/usr/bin/env bash
# Общие вспомогательные функции
SSH_USER="root"

run() {  # run <host> <command>
  local host="$1"; shift
  # Если скрипт запущен **на самом RedOS** (192.168.0.23) или указали localhost,
  # выполняем команду напрямую, иначе через SSH.
  if [[ "$host" == "192.168.0.23" || "$host" == "localhost" ]]; then
    "$@"
  else
    ssh -o StrictHostKeyChecking=no "${SSH_USER}@${host}" "$@"
  fi
}
}@${host}" "$@"
}

# ensure_line <host> <file> <line>
ensure_line() {
  local host="$1" file="$2" line="$3"
  if ! run "$host" "grep -qF -- \"$line\" \"$file\""; then
    run "$host" "echo '$line' >> $file"
  fi
}

# iptables_add <host> <table> <rule>
iptables_add() {
  local host="$1" table="$2" rule="$3"
  if ! run "$host" "iptables -t $table -C $rule 2>/dev/null"; then
    run "$host" "iptables -t $table -A $rule"
  fi
}
