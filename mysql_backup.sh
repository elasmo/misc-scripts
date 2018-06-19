#!/bin/sh
#
# 2017
script_name="$(basename $0)"

mysql_user="user"
mysql_password="pass"
mysql_host="host"

db_ignore="Database information_schema performance_schema sys"
mysql_dump="/usr/local/bin/mysqldump"
mysql_bin="/usr/local/bin/mysql"
dump_perms=644

db_list="$(${mysql_bin} -h ${mysql_host} -u ${mysql_user} \
         -p${mysql_password} -e 'show databases')"

if [ $? -ne 0 ]
then
    logger -t ${script_name} "Unable to list databases."
    exit 1;
fi

for db in ${db_list}
do
	ignored=0
    for i in ${db_ignore}
    do
        if [ "${db}" == "${i}" ]
        then
            echo "Ignoring database '${db}'."
            ignored=1
        fi
    done

    if [ ${ignored} -eq 1 ]
    then
        continue
    fi
            
    dump_file="${db}.sql"
    ${mysql_dump} -u${mysql_user} -p${mysql_password} -h${mysql_host} \
        "${db}" > "${dump_file}"

    if [ $? -ne 0 ]
    then
        logger -t ${script_name} "Unable to dump database '${db}'."
        exit 1
    fi
    chmod ${dump_perms} ${dump_file}
    bzip2 ${dump_file}
done

if [ $? -eq 0 ]
then
    logger -t ${script_name} "MySQL backup sucessful."
    exit 0
else
    logger -t ${script_name} "Unknown error."
    exit 1
fi
