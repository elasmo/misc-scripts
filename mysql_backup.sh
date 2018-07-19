#!/usr/bin/env bash
set -euo pipefail

export PATH="${PATH}:/usr/local/bin"

script_name="$(basename $0)"
user=""
password=""
host=""
perms=600

databases=(
    "db1"
    "db2"
)

error() {
    logger -t ${script_name} "$@ $-"
    exit 1
}

for database in ${databases[@]}; do
    db_dump="${database}.sql"
    mysqldump -u ${user} -p${password} -h ${host} ${database} > $db_dump || error "Database error while working on ${database}"
    chmod ${perms} ${db_dump}
    bzip2 ${db_dump} || error "Compressing ${db_dump} failed"
done

logger -t ${script_name} "MySQL backup sucessful"
