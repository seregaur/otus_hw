#!/usr/bin/env bash

set -o errexit

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")


PG_DATADIR="${PROJECT_DIR}/data/postgres"
PGADMIN_DATADIR="${PROJECT_DIR}/data/pgadmin"
PGADMIN_DEFAULT_EMAIL="admin@localhost"
PGADMIN_DEFAULT_PASSWORD="VDgwcc8h"
WEB_UI_URL="http://127.0.0.1"

source "${WORKDIR}/env.sh"

if ! [ -d "${PG_DATADIR}" ]; then
  mkdir -p "${PG_DATADIR}"
fi

if ! [ -d "${PGADMIN_DATADIR}" ]; then
  mkdir -p "${PGADMIN_DATADIR}"
  sudo chown -R 5050:5050 ${PGADMIN_DATADIR}
fi

#sudo chown -R ${PG_UID}:${PG_GID} ${PG_DATADIR}
docker network ls | grep -q ${PG_NETWORK} || docker network create ${PG_NETWORK}

docker run -d --rm \
  --name ${PG_CONTAINER_NAME} \
  --network ${PG_NETWORK} \
  -e "POSTGRES_PASSWORD=${PG_PASS}" \
  -v ${PG_DATADIR}:/var/lib/postgresql/data \
  -p 5432:5432 \
  ${PG_IMAGE}

docker run -d --rm \
  --name ${PGADMIN_CONTAINER_NAME} \
  --network ${PG_NETWORK} \
  -e "PGADMIN_DEFAULT_EMAIL=${PGADMIN_DEFAULT_EMAIL}" \
  -e "PGADMIN_DEFAULT_PASSWORD=${PGADMIN_DEFAULT_PASSWORD}" \
  -v ${PGADMIN_DATADIR}:/var/lib/pgadmin \
  -p 80:80 \
  dpage/pgadmin4

(sleep 5; xdg-open "${WEB_UI_URL}" 2>/dev/null >/dev/null) &





