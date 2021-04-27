#!/usr/bin/env bash

#set -e

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/common.sh

main(){
  for rs in RS1 RS2 RS3; do
    for db in DB1 DB2 DB3; do
      stop_container "${rs}-${db}"
    done
  done

  for conf in CONF1 CONF2 CONF3; do
    stop_container ${conf}
  done

  stop_container MONGO_CLUSTER1
  stop_container MONGO_CLUSTER2

  docker network rm ${DOCKER_NETWORK}
}

main
