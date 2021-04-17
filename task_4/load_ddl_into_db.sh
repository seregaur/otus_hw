#!/usr/bin/env bash

#set -x
set -e

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")
DB_NAME=otus
DDL_FILE="${WORKDIR}/ddl.sql"

source ${PROJECT_DIR}/task_3/env.sh

main()
{
  echo "Ждем запуска ${PG_CONTAINER_NAME}"
  wait_pg_container "${PG_CONTAINER_NAME}"

  echo "Создаем базу данных"
  do_sql_cmd "${PG_CONTAINER_NAME}" "drop database ${DB_NAME}" || echo
  do_sql_cmd "${PG_CONTAINER_NAME}" "create database ${DB_NAME}"

  echo "Создаем DDL"
  cat ${DDL_FILE}| docker exec -u 999 -i ${PG_CONTAINER_NAME}  psql -d ${DB_NAME} -f -
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

  echo ${PG_PASS} | docker run -i --rm \
    --name psql_temp_container \
    --network ${PG_NETWORK} \
    ${PG_IMAGE} \
    psql 2>/dev/null ${psql_arg} -h ${server} -U postgres -c "${sqlquery}"
}

main