#!/bin/bash

usage() {
    echo "$(basename $0) [OPTION]... [FILE]..."
    echo ""
    echo "Create ToricCY mongodb database users."
    echo ""
    echo "Options:"
    echo "  --host                       Hostname/IP address"
    echo "  --port                       Port"
    echo "  --db                         Database"
    echo "  --username_admin             Admin user username"
    echo "  --password_admin             Admin user password"
    echo "  --username_rw                Read-write user username"
    echo "  --password_rw                Read-write user password"
    echo "  --username_r                 Read user username"
    echo "  --password_r                 Read user password"
    echo "  -h, --help        Display this help and exit"
    echo -e ${msg}
}

HOST="localhost"
PORT="27017"
DB=""
USERNAME_ADMIN=""
PASSWORD_ADMIN=""
USERNAME_RW=""
PASSWORD_RW=""
USERNAME_R=""
PASSWORD_R=""

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
        --username_admin)
            USERNAME_ADMIN=$2
            shift
            shift
            ;;
        --password_admin)
            PASSWORD_ADMIN=$2
            shift
            shift
            ;;
        --username_rw)
            USERNAME_RW=$2
            shift
            shift
            ;;
        --password_rw)
            PASSWORD_RW=$2
            shift
            shift
            ;;
        --username_r)
            USERNAME_R=$2
            shift
            shift
            ;;
        --password_r)
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

mongo --host ${HOST} \
      --port ${PORT} \
      --authenticationDatabase admin \
      --eval "db.createUser({'user': '${USERNAME_ADMIN}',
                             'pwd': '${PASSWORD_ADMIN}',
                             'roles': [{'role': 'root',
                                          'db': 'admin'}]})" admin

mongo --host ${HOST} \
      --port ${PORT} \
      --authenticationDatabase admin \
      --eval "db.createUser({'user': '${USERNAME_RW}',
                             'pwd': '${PASSWORD_RW}',
                             'roles': [{'role': 'readWrite',
                                          'db': '${DB}'}]})" ${DB}

mongo --host ${HOST} \
      --port ${PORT} \
      --authenticationDatabase admin \
      --eval "db.createUser({'user': '${USERNAME_R}',
                             'pwd': '${PASSWORD_R}',
                             'roles': [{'role': 'read',
                                          'db': '${DB}'}]})" ${DB}
