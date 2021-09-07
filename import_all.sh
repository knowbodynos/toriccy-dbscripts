#!/bin/bash

usage() {
    echo "$(basename $0) [OPTIONS]..."
    echo ""
    echo "Import ToricCY mongodb files into database."
    echo ""
    echo "Options:"
    echo "  --host            Hostname/IP address"
    echo "  --port            Port"
    echo "  --db              Database"
    echo "  --username        Username"
    echo "  --password        Password"
    echo "  --files_dir       Files dir"
    echo "  -h, --help        Display this help and exit"
    echo -e ${msg}
}

HOST="localhost"
PORT="27017"
DB=""
USERNAME_RW=""
PASSWORD_RW=""
FILES_DIR=""

DIR=$(dirname ${BASH_SOURCE[0]})

while [ $# -gt 0 ]; do
    case "$1" in
        --host)
            HOST=$2
            shift
            shift
            ;;
        --port)
            PORT=$2
            shift
            shift
            ;;
        --db)
            DB=$2
            shift
            shift
            ;;
        --username)
            USERNAME_RW=$2
            shift
            shift
            ;;
        --password)
            PASSWORD_RW=$2
            shift
            shift
            ;;
        --files_dir)
          FILES_DIR=$2
            shift
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            exit 1
            ;;
    esac
done

if [ -z ${HOST} ] || [ -z ${PORT} ] || [ -z ${DB} ] || [ -z ${USERNAME_RW} ] || [ -z ${PASSWORD_RW} ]; then
    usage
    exit 1
fi

mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=INDEXES --mode="upsert" --file="${FILES_DIR}/indexes.json"

for i in {1..6}; do
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=POLY --mode="upsert" --file="${FILES_DIR}/00${i}.poly.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=GEOM --mode="upsert" --file="${FILES_DIR}/00${i}.geom.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=TRIANG --mode="upsert" --file="${FILES_DIR}/00${i}.triang.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=INVOL --mode="upsert" --file="${FILES_DIR}/00${i}.invol.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=SWISSCHEESE --mode="upsert" --file="${FILES_DIR}/00${i}.swisscheese.json"
done

while read line; do
     mongo --host=${HOST} --port ${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --eval "$(echo ${line} | sed 's/"/\"/g')" ${DB}
     wait
done < ${DIR}/indexes
