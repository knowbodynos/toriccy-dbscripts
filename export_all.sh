#!/bin/bash

usage() {
    echo "$(basename $0) [OPTIONS]..."
    echo ""
    echo "Export ToricCY mongodb database to files."
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
USERNAME_R=""
PASSWORD_R=""

DIR=$(dirname "${BASH_SOURCE[0]}")
. ${DIR}/secrets.sh

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
            USERNAME_R=$2
            shift
            shift
            ;;
        --password)
            PASSWORD_R=$2
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

if [ -z ${HOST} ] || [ -z ${PORT} ] || [ -z ${DB} ] || [ -z ${USERNAME_R} ] || [ -z ${PASSWORD_R} ]; then
    usage
    exit 1
fi

mongoexport --host=${HOST} --port=${PORT} --username=${USERNAME_R} --password=${PASSWORD_R} --db=${DB} --collection=INDEXES --out=indexes.json

for i in {1..6}; do
    mongoexport --host=${HOST} --port=${PORT} --username=${USERNAME_R} --password=${PASSWORD_R} --db=${DB} --collection=POLY --query="{'H11': ${i}}" --out="00${i}.poly.json"
    mongoexport --host=${HOST} --port=${PORT} --username=${USERNAME_R} --password=${PASSWORD_R} --db=${DB} --collection=GEOM --query="{'H11': ${i}}" --out="00${i}.geom.json"
    mongoexport --host=${HOST} --port=${PORT} --username=${USERNAME_R} --password=${PASSWORD_R} --db=${DB} --collection=TRIANG --query="{'H11': ${i}}" --out="00${i}.triang.json"
    mongoexport --host=${HOST} --port=${PORT} --username=${USERNAME_R} --password=${PASSWORD_R} --db=${DB} --collection=INVOL --query="{'H11': ${i}}" --out="00${i}.invol.json"
    mongoexport --host=${HOST} --port=${PORT} --username=${USERNAME_R} --password=${PASSWORD_R} --db=${DB} --collection=SWISSCHEESE --query="{'H11': ${i}}" --out="00${i}.swisscheese.json"
done

