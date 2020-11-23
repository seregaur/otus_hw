#!/usr/bin/env bash
set -o errexit

WORKDIR=$(dirname "$(realpath "$0")")

source "${WORKDIR}/env.sh"
docker exec -it -u $PG_UID $PG_CONTAINER_NAME psql