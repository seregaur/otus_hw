#!/usr/bin/env bash

set -e

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/env.sh

main()
{
  create_pg_server "${PG_CONTAINER_NAME}" "${TASK_DATA_DIR}/master" "5432"

  wait_pg_container "${PG_CONTAINER_NAME}"

  prepare_server_for_replication "${PG_CONTAINER_NAME}" "${TASK_DATA_DIR}/master"

  docker stop "${PG_CONTAINER_NAME}"
  create_pg_server "${PG_CONTAINER_NAME}" "${TASK_DATA_DIR}/master" "5432"
  wait_pg_container "${PG_CONTAINER_NAME}"

  prepare_replica_data "${PG_CONTAINER_NAME}" "${TASK_DATA_DIR}/replica1" "test_slot" "5min"

  create_pg_server "replica1" "${TASK_DATA_DIR}/replica1" "5433"

  do_sql_cmd "${PG_CONTAINER_NAME}" "drop database ${PG_TESTDB_NAME}" || echo
  do_sql_cmd "${PG_CONTAINER_NAME}" "create database ${PG_TESTDB_NAME}"

  cat ${WORKDIR}/test-ddl.sql | docker exec -u 999 -i ${PG_CONTAINER_NAME} psql -d ${PG_TESTDB_NAME} -f -
  cat ${WORKDIR}/test-data.sql | docker exec -u 999 -i ${PG_CONTAINER_NAME} psql -d ${PG_TESTDB_NAME} -f -

  do_sql_cmd "${PG_CONTAINER_NAME}" "create publication account_publ for table accounts" "${PG_TESTDB_NAME}"

  create_pg_server "${PG_LOGICAL_REPLICA}" "${TASK_DATA_DIR}/logical_replica"
  wait_pg_container "${PG_LOGICAL_REPLICA}"

  do_sql_cmd "${PG_LOGICAL_REPLICA}" "drop database ${PG_TESTDB_NAME}" || echo
  do_sql_cmd "${PG_LOGICAL_REPLICA}" "create database ${PG_TESTDB_NAME}"

  cat test-ddl.sql | docker exec -u 999 -i ${PG_LOGICAL_REPLICA}  psql -d ${PG_TESTDB_NAME} -f -

  local connection="host=${PG_CONTAINER_NAME} port=5432 user=postgres password=${PG_ADMIN_PASS} dbname=${PG_TESTDB_NAME}"

  local create_subscription="create subscription accounts_sub connection '${connection}' publication account_publ"
  do_sql_cmd "${PG_LOGICAL_REPLICA}" "${create_subscription}" "${PG_TESTDB_NAME}"
}

create_pg_server()
{
  local container_name="${1}"
  local data_dir="${2}"
  local port="${3}"

  if [ -n "${port}" ]; then
    local docker_args="-p ${port}:5432"
  fi

  docker ps | grep -q ${container_name} || docker run -d --rm \
    --name ${container_name} \
    --network ${PG_NETWORK} ${docker_args} \
    -e "POSTGRES_PASSWORD=${PG_ADMIN_PASS}" \
    -v "${data_dir}":/var/lib/postgresql/data \
    ${PG_IMAGE}
}

wait_pg_container()
{
  local container_name=$1
  until (do_sql_cmd "${container_name}" "select 1"); do
    sleep 1
    echo -n "."
  done
}

do_sql_cmd()
{
  local server="${1}"
  local sqlquery="${2}"
  local dbname="${3}"

  local psql_arg="-qt"

  if [ -n "${dbname}" ]; then
    psql_arg+=" -d ${dbname}"
  fi

  echo ${PG_ADMIN_PASS} | docker run -i --rm \
    --name psql_temp_container \
    --network ${PG_NETWORK} \
    ${PG_IMAGE} \
    psql ${psql_arg} -h ${server} -U postgres -c "${sqlquery}"
}

prepare_server_for_replication()
{
  local container_name="${1}"
  local data_dir="${2}"

  if [ -z "$(do_sql_cmd "${container_name}" "SELECT 1 FROM pg_roles WHERE rolname='replicator'")" ]; then
    do_sql_cmd "${container_name}" "CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD '${PG_REPLICATOR_PASS}'"
  fi

  echo 'host replication replicator all md5' | sudo tee -a "${data_dir}/pg_hba.conf"
  sudo sed '/wal_level/d' -i "${data_dir}/postgresql.conf"
  echo 'wal_level = logical' | sudo tee -a "${data_dir}/postgresql.conf"
}

prepare_replica_data()
{
  local master_name="${1}"
  local replica_dir="${2}"
  local slot_name="${3}"
  local delay="${4}"

  if [ -d $replica_dir ]; then
    exit 1
  fi

  if [ -n "${slot_name}" ]; then
    if [ -z "$(do_sql_cmd "${master_name}" "SELECT 1 from pg_replication_slots where slot_name='${master_name}'")" ]; then
      local slot_arg="--slot=${slot_name} -C"
    fi
  fi

  echo ${PG_REPLICATOR_PASS} | docker run -i --rm \
    --name create_replica \
    --network pg_net \
    -v "${replica_dir}":/backup \
    postgres:13 \
    pg_basebackup -h ${master_name} -U replicator -p 5432 -D /backup -Fp -Xs -P -R ${slot_arg}

  if [ -n "${delay}" ]; then
    sudo sed '/recovery_min_apply_delay/d' \
      -i ${replica_dir}/postgresql.conf
    echo recovery_min_apply_delay = ${delay} \
      | sudo tee -a ${replica_dir}/postgresql.conf
  fi
}


main