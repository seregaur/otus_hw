#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "./mongo-cmd <команда>"
  exit 1
fi

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/env.sh

touch "${WORKDIR}/.dbshell"
chmod 666 "${WORKDIR}/.dbshell"

docker run -it --rm \
    --name mongo_cmd \
    --network ${DOCKER_NETWORK} \
    -v ${PWD}:/home/mongodb/ \
    ${MONGO_IMAGE} \
    "$@"