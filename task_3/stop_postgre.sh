#!/usr/bin/env bash

set -o errexit

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source "${WORKDIR}/env.sh"

docker stop ${PG_CONTAINER_NAME}
docker stop ${PGADMIN_CONTAINER_NAME}
docker network rm ${PG_NETWORK}
