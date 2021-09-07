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
    echo "  --files_dir       Files dir"
    echo "  -h, --help        Display this help and exit"
    echo -e ${msg}
}

mongoexport_func() {
    mongoexport --host=${HOST} \
                --port=${PORT} \
                --username=${USERNAME_R} \
                --password=${PASSWORD_R} \
                --db=${DB}
                "$@"
}

DIR=$(dirname ${BASH_SOURCE[0]})

HOST="localhost"
PORT="27017"
DB="ToricCY"
USERNAME_R=""
PASSWORD_R=""
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
            USERNAME_R=$2
            shift
            shift
            ;;
        --password)
            PASSWORD_R=$2
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

if [ -z ${HOST} ] || [ -z ${PORT} ] || [ -z ${DB} ] || [ -z ${USERNAME_R} ] || [ -z ${PASSWORD_R} ] || [ -z ${FILES_DIR} ]; then
    usage
    exit 1
fi

echo "Exporting '${DB}.INDEXES'"
mongoexport_func --collection=INDEXES --out="${FILES_DIR}/indexes.json"
wait

for i in {1..6}; do
    echo "Exporting '${DB}.POLY.H11': ${i}..."
    mongoexport_func --query="{'H11': ${i}}" \
                     --collection=POLY \
                     --out="${FILES_DIR}/00${i}.poly.json"
    wait
    echo "Exporting '${DB}.GEOM.H11': ${i}..."
    mongoexport_func --query="{'H11': ${i}}" \
                     --collection=GEOM \
                     --out="${FILES_DIR}/00${i}.geom.json"
    wait
    echo "Exporting '${DB}.TRIANG.H11': ${i}..."
    mongoexport_func --query="{'H11': ${i}}" \
                     --collection=TRIANG \
                     --out="${FILES_DIR}/00${i}.triang.json"
    wait
    echo "Exporting '${DB}.SWISSCHEESE.H11': ${i}..."
    mongoexport_func --query="{'H11': ${i}}" \
                     --collection=SWISSCHEESE \
                     --out="${FILES_DIR}/00${i}.swisscheese.json"
    wait
    echo "Exporting '${DB}.INVOL.H11': ${i}..."
    mongoexport_func --query="{'H11': ${i}}" \
                     --collection=INVOL \
                     --out="${FILES_DIR}/00${i}.invol.json"
    wait
done
