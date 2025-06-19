#!/usr/bin/env bash
# Общие вспомогательные функции
SSH_USER="root"

#################################
# run <host> <command...>
# Если host = 192.168.0.23 (RedOS, где скрипт запущен) или localhost — выполняем локально.
# Иначе отправляем через SSH.  Команда может приходить «как есть» одной строкой
# (мы оборачиваем её в bash -c), поэтому кавычки внутри строки сохраняются.
#################################
run() {
  local host="$1"; shift
  local cmd="$*"
  if [[ "$host" == "192.168.0.23" || "$host" == "localhost" ]]; then
    bash -c "$cmd"
  else
    ssh -o StrictHostKeyChecking=no "${SSH_USER}@${host}" "$cmd"
  fi
}

# ensure_line <host> <file> <line>
ensure_line() {
  local host="$1" file="$2" line="$3"
  # Создаём файл, если нет
  run "$host" "mkdir -p $(dirname $file) && touch $file"
  if ! run "$host" "grep -qF -- \"$line\" \"$file\""; then
    run "$host" "echo \"$line\" >> $file"
  fi
}

# iptables_add <host> <table> <rule>
iptables_add() {
  local host="$1" table="$2" rule="$3"
  if ! run "$host" "iptables -t $table -C $rule 2>/dev/null"; then
    run "$host" "iptables -t $table -A $rule"
  fi
}
