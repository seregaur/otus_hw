#!/usr/bin/env bash

#set -x

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/common.sh

create_container MONGO_CLUSTER1 mongos --configdb RScfg/CONF1:27019,CONF2:27019,CONF3:27019 --bind_ip_all --port=27017
create_container MONGO_CLUSTER2 mongos --configdb RScfg/CONF1:27019,CONF2:27019,CONF3:27019 --bind_ip_all --port=27017
