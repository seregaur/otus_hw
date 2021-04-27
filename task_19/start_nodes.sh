#!/usr/bin/env bash

#set -x

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/common.sh

docker network ls | grep -q ${DOCKER_NETWORK} || docker network create ${DOCKER_NETWORK}

for rs in RS1 RS2 RS3; do
  for db in DB1 DB2 DB3; do
    create_container "${rs}-${db}" --shardsvr --replSet=${rs}
  done
done

for conf in CONF1 CONF2 CONF3; do
  create_container ${conf} --configsvr --replSet=RSconf
done

