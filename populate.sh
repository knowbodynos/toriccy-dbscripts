#!/bin/bash

usage() {
    echo "$(basename $0) [OPTION]... [FILE]..."
    echo ""
    echo "Populate ToricCY mongodb database."
    echo ""
    echo "Options:"
    echo "  -U               Admin user username"
    echo "  -P               Admin user password"
    echo "  -u                Read-write user username"
    echo "  -p                Read-write user password"
    echo "  --port            Port"
    echo "  -h, --help        Display this help and exit"
    echo -e ${msg}
}

USER_ADMIN=""
PASS_ADMIN=""

USER_RW=""
PASS_RW=""

DBNAME="ToricCY"
PORT="27017"

while [ $# -gt 0 ]; do
    case "$1" in
        -U)
            USER_ADMIN=$2
            shift
            shift
            ;;
        -P)
            PASS_ADMIN=$2
            shift
            shift
            ;;
        -u)
            USER_RW=$2
            shift
            shift
            ;;
        -p)
            PASS_RW=$2
            shift
            shift
            ;;
        --db|-d)
            DBNAME=$2
            shift
            shift
            ;;
        --port)
            PORT=$2
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

mongo --port ${PORT} --eval "db.createUser({'user':'${USER_ADMIN}','pwd':'${PASS_ADMIN}','roles':[{'role':'root','db':'admin'}]})" admin

mongo --port ${PORT} --eval "db.createUser({'user':'${USER_RW}','pwd':'${PASS_RW}','roles':[{'role':'readWrite','db':'ToricCY'}]}); db.createUser({'user':'frontend','pwd':'password','roles':[{'role':'read','db':'ToricCY'}]});" ToricCY

mongoimport --port ${PORT} --db ${DBNAME} --collection INDEXES --file all.indexes --batchSize 10

for i in {1..6}; do
    mongoimport --port ${PORT} --db ${DBNAME} --collection POLY --file 00${i}.poly --batchSize 100
    wait
    mongoimport --port ${PORT} --db ${DBNAME} --collection GEOM --file 00${i}.geom --batchSize 100
    wait
    mongoimport --port ${PORT} --db ${DBNAME} --collection TRIANG --file 00${i}.triang --batchSize 100
    wait
    mongoimport --port ${PORT} --db ${DBNAME} --collection INVOL --file 00${i}.invol --batchSize 100
    wait
    mongoimport --port ${PORT} --db ${DBNAME} --collection SWISSCHEESE --file 00${i}.swisscheese --batchSize 100
    wait
done

while read line; do
     mongo --port ${PORT} --eval "$(echo ${line} | sed 's/"/\"/g')" ${DBNAME}
     wait
done < indexes

