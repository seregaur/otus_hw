#!/usr/bin/env bash

set -e

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

source ${WORKDIR}/env.sh

main()
{
  create_pg_server "${PG_CONTAINER_NAME}" "${TASK_DATA_DIR}/master" "5432"

  until (do_sql_cmd "${PG_CONTAINER_NAME}" "select 1"); do
    sleep 1
    echo -n "."
  done

  prepare_server_for_replication "${PG_CONTAINER_NAME}"
  prepare_replica_data "${PG_CONTAINER_NAME}" "${TASK_DATA_DIR}/replica1" "test_slot" "5min"

  create_pg_server "replica1" "${TASK_DATA_DIR}/replica1" "5433"

  do_sql_cmd "{PG_CONTAINER_NAME}" "drop database test_data" || echo
  do_sql_cmd "{PG_CONTAINER_NAME}" "create database test_data"

  cat ${WORKDIR}/test-ddl.sql | docker exec -u 999 -i ${PG_CONTAINER_NAME} psql -d test_data -f -
  cat ${WORKDIR}/test-data.sql | docker exec -u 999 -i ${PG_CONTAINER_NAME} psql -d test_data -f -
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

do_sql_cmd()
{
  local server="${1}"
  local sqlquery="${2}"

  echo ${PG_ADMIN_PASS} | docker run -i --rm \
    --name psql_temp_container \
    --network ${PG_NETWORK} \
    ${PG_IMAGE} \
    psql -qt -h postgres_srv -U postgres -c "${sqlquery}"
}

prepare_server_for_replication()
{
  local container_name="${1}"

  if [ -z "$(do_sql_cmd "${container_name}" "SELECT 1 FROM pg_roles WHERE rolname='replicator'")" ]; then
    do_sql_cmd "${container_name}" "CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD '${PG_REPLICATOR_PASS}'"
  fi

  docker exec ${container_name} \
    bash -c "cat /var/lib/postgresql/data/pg_hba.conf | grep -q 'host replication replicator all md5'" \
  || (docker exec ${container_name} \
        bash -c "echo 'host replication replicator all md5' >> /var/lib/postgresql/data/pg_hba.conf" &&
      docker exec -u $PG_UID ${container_name} bash -c "pg_ctl reload")
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