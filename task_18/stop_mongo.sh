#!/usr/bin/env bash

set -e

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/env.sh
docker-compose -f "${WORKDIR}/docker-compose.yml" down -v
sudo rm -rf ${MONGO_DATA_DIR}