#!/usr/bin/env bash

export PG_UID=999
export PG_GID=999
export PG_NETWORK=pg_net
export PG_CONTAINER_NAME="postgres_srv"
export PGADMIN_CONTAINER_NAME="pgadmin"
export TASK_DATA_DIR=${PROJECT_DIR}/data/task_15
export PG_IMAGE="postgres:13"
export PG_ADMIN_PASS="FmbeSSJUOvxX6wLB"
export PG_REPLICATOR_PASS="KNBc9sdhcncs0sd"
export PG_TESTDB_NAME="test_data"
