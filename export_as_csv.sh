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
    echo "  --type            Output file type (json, csv)"
    echo "  --files_dir       Files dir"
    echo "  -h, --help        Display this help and exit"
    echo -e ${msg}
}

mongoexport_func() {
    mongoexport --host=${HOST} \
                --port=${PORT} \
                --username=${USERNAME_R} \
                --password=${PASSWORD_R} \
                --db=${DB} \
                "$@"
}

DIR=$(dirname ${BASH_SOURCE[0]})

HOST="localhost"
PORT="27017"
DB="ToricCY"
USERNAME_R=""
PASSWORD_R=""
TYPE="json"
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
	--type)
	    TYPE=$2
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

for i in {1..6}; do
    echo "Exporting '${DB}.POLY.H11': ${i}..."
    mongoexport_func --query="{\"H11\": ${i}}" \
                     --collection=POLY \
                     --type="${TYPE}" \
		     --fields="BASIS,H21,NVERTS,DTOJ,EULER,DRESVERTS,NNPOINTS,POLYID,FAV,NDVERTS,DVERTS,FUNDGP,H11,CWS,NNVERTS,RESCWS,NGEOMS,NALLTRIANGS,INVBASIS,JTOD,NDPOINTS,POLYN" \
		     --out="${FILES_DIR}/00${i}.poly.${TYPE}"
    wait
    echo "Exporting '${DB}.GEOM.H11': ${i}..."
    mongoexport_func --query="{\"H11\": ${i}}" \
                     --collection=GEOM \
                     --type="${TYPE}" \
		     --fields="MORIMAT,CHERN2XJ,KAHLERMAT,IPOLYXJ,NTRIANGS,POLYID,CHERN2XNUMS,H11,GEOMN,ITENSXJ" \
		     --out="${FILES_DIR}/00${i}.geom.${TYPE}"
    wait
    echo "Exporting '${DB}.TRIANG.H11': ${i}..."
    mongoexport_func --query="{\"H11\": ${i}}" \
                     --collection=TRIANG \
		     --type="${TYPE}" \
		     --fields="CHERNAD,TRIANG,TRIANGN,POLYID,ALLTRIANGN,CHERNAJ,ITENSXD,SRIDEAL,CHERN3XD,CHERN3XJ,CHERN2XD,H11,GEOMN,KAHLERMATP,IPOLYAD,MORIMATP,IPOLYXD,IPOLYAJ,ITENSAD,ITENSAJ,DIVCOHOM,NINVOL" \
                     --out="${FILES_DIR}/00${i}.triang.${TYPE}"
    wait
    echo "Exporting '${DB}.SWISSCHEESE.H11': ${i}..."
    mongoexport_func --query="{\"H11\": ${i}}" \
                     --collection=SWISSCHEESE \
                     --type="${TYPE}" \
		     --fields="GEOMN,NLARGE,POLYID,HOM,RMAT4CYCLE,H11,INTBASIS4CYCLE,RMAT2CYCLE,INTBASIS2CYCLE" \
		     --out="${FILES_DIR}/00${i}.swisscheese.${TYPE}"
    wait
    echo "Exporting '${DB}.INVOL.H11': ${i}..."
    mongoexport_func --query="{\"H11\": ${i}}" \
                     --collection=INVOL \
		     --type="${TYPE}" \
		     --fields="TRIANGN,POLYID,H11,INVOL,INVOLN,GEOMN,H21+,H21-,OPLANES,NSYMCYTERMS,H11+,H11-,NCYTERMS,INVOLDIVCOHOM,CYPOLY,SYMCYPOLY,SRINVOL,ITENSXDINVOL,SMOOTH,VOLFORMPARITY" \
                     --out="${FILES_DIR}/00${i}.invol.${TYPE}"
    wait
done
