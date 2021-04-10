#!/usr/bin/env bash

set -e

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")
MY_CONTAINERS=( ${PG_CONTAINER_NAME} replica1 )

source ${WORKDIR}/env.sh

for container in "${MY_CONTAINERS[@]}"; do
  docker ps | grep -q ${container} && docker stop ${container}
done
sleep 10
sudo rm -rf ${TASK_DATA_DIR}/*