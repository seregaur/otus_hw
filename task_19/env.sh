#!/usr/bin/env bash

export MONGO_USER=root
export MONGO_PASSWORD=password
export MONGO_DATA_DIR=${PROJECT_DIR}/data/task_18
export MONGO_IMAGE="mongo:4.4"
export MONGO_CONTAINER_NAME="mongo-srv1"
export DOCKER_NETWORK="cluster-net"
