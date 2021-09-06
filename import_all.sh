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
    echo "  -h, --help        Display this help and exit"
    echo -e ${msg}
}

HOST=""
PORT=""
DB=""
USERNAME_RW=""
PASSWORD_RW=""

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

mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=INDEXES --file=indexes.json

for i in {1..6}; do
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=POLY --file="00${i}.poly.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=GEOM --file="00${i}.geom.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=TRIANG --file="00${i}.triang.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=INVOL --file="00${i}.invol.json"
    mongoimport --host=${HOST} --port=${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --db=${DB} --collection=SWISSCHEESE --file="00${i}.swisscheese.json"
done

while read line; do
     mongo --host=${HOST} --port ${PORT} --username=${USERNAME_RW} --password=${PASSWORD_RW} --eval "$(echo ${line} | sed 's/"/\"/g')" ${DB}
     wait
done < ${DIR}/indexes
