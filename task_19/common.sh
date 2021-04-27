#!/usr/bin/env bash

#set -x

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/env.sh

create_container(){
  local name=$1
  shift
  local args="$@"

  local datadir="${PROJECT_DIR}/data/task_19/${name}"
  mkdir -p "${datadir}"

  docker run -d \
    --name ${name} \
    --network ${DOCKER_NETWORK} \
    -v ${datadir}:/data/db \
    ${MONGO_IMAGE} \
    ${args}
}

stop_container(){
  local name=$1

  local datadir="${PROJECT_DIR}/data/task_19/${name}"

  docker stop ${name}
  docker rm ${name}
  sudo rm -rf ${datadir}
}