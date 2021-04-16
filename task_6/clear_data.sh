#!/usr/bin/env bash

set -e

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/env.sh

MY_CONTAINERS=( $PG_CONTAINER_NAME replica1 logical_replica )

for container in "${MY_CONTAINERS[@]}"; do
  docker ps | grep -q ${container} && docker stop ${container}
done
sudo rm -rf ${TASK_DATA_DIR}/*