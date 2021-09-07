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

mongoimport_func() {
    mongoimport --host=${HOST} \
                --port=${PORT} \
                --username=${USERNAME_RW} \
                --password=${PASSWORD_RW} \
                --db=${DB} \
                --mode="upsert" \
                --batchSize 100 \
                "$@"
}

DIR=$(dirname ${BASH_SOURCE[0]})

HOST="localhost"
PORT="27017"
DB="ToricCY"
USERNAME_RW=""
PASSWORD_RW=""
FILES_DIR="${DIR}"

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

if [ -z ${HOST} ] || [ -z ${PORT} ] || [ -z ${DB} ] || [ -z ${USERNAME_RW} ] || [ -z ${PASSWORD_RW} ] || [ -z ${FILES_DIR} ]; then
    usage
    exit 1
fi



echo "Importing '${DB}.INDEXES'"
mongoimport_func --collection=INDEXES --file="${FILES_DIR}/indexes.json"
wait

for i in {1..6}; do
    echo "Importing '${DB}.POLY.H11': ${i}..."
    mongoimport_func --collection=POLY --file="${FILES_DIR}/00${i}.poly.json"
    wait
    echo "Importing '${DB}.GEOM.H11': ${i}..."
    mongoimport_func --collection=GEOM --file="${FILES_DIR}/00${i}.geom.json"
    wait
    echo "Importing '${DB}.TRIANG.H11': ${i}..."
    mongoimport_func --collection=TRIANG --file="${FILES_DIR}/00${i}.triang.json"
    wait
    echo "Importing '${DB}.SWISSCHEESE.H11': ${i}..."
    mongoimport_func --collection=SWISSCHEESE --file="${FILES_DIR}/00${i}.swisscheese.json"
    wait
    echo "Importing '${DB}.INVOL.H11': ${i}..."
    mongoimport_func --collection=INVOL --file="${FILES_DIR}/00${i}.invol.json"
    wait
done

echo "Indexing..."
mongo --host=${HOST} \
      --port ${PORT} \
      --username=${USERNAME_RW} \
      --password=${PASSWORD_RW} \
      --authenticationDatabase=${DB} < ${DIR}/indexes.js

echo "Done!"
