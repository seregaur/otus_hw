#!/usr/bin/env bash

#set -x

DES3_PASSWD="password"

WORKDIR=$(dirname "$(realpath "$0")")
PROJECT_DIR=$(dirname "${WORKDIR}")

DATA_DIR="${PROJECT_DIR}/data/task_29"

mkdir -p ${DATA_DIR}/{backup,mysql}

XBSTREAM_FILE="${WORKDIR}/backups/backup.xbstream.gz-4560-0d8b3a.des3"
MYSQLDUMP_FILE="${WORKDIR}/backups/otus_db-4560-3521f1.dmp"

openssl des3 --md md5 -d -in ${XBSTREAM_FILE} -salt -k ${DES3_PASSWD} | \
  gzip -d | \
  docker run -i --name percona-xtrabackup --rm \
    -v ${DATA_DIR}/backup:/backup \
    percona/percona-xtrabackup:8.0 \
    xbstream -x -C /backup

docker run -i --name percona-xtrabackup --rm \
  -v ${DATA_DIR}/backup:/backup \
  percona/percona-xtrabackup:8.0 \
  xtrabackup --prepare --export --target-dir=/backup

docker run -d --name percona-server --rm \
  -e MYSQL_ROOT_PASSWORD=12345 \
  -v $HOME/otus_hw/data/task_29/backup:/backup \
  -v $HOME/otus_hw/data/task_29/mysql:/var/lib/mysql \
  percona/percona-server:8.0

until (docker exec -it percona-server mysql -s -u root --password=12345 -e 'select 1'); do
  sleep 1
  echo -n "."
done

docker exec -it percona-server mysql -s -u root --password=12345 -e 'create database if not exists `otus`'

cat ${MYSQLDUMP_FILE} | \
  docker exec -i percona-server bash -c "mysql -u root --password=12345 otus"

docker exec -it percona-server mysql -s -u root --password=12345 otus -e 'alter table articles discard tablespace'
sudo bash -c "cp ${DATA_DIR}/backup/otus/articles.* ${DATA_DIR}/mysql/otus/"
sudo bash -c "chown 1001:1001 ${DATA_DIR}/mysql/otus/articles.*"
docker exec -it percona-server mysql -s -u root --password=12345 otus -e 'alter table articles import tablespace'
docker exec -it percona-server mysql -u root --password=12345 otus -e 'select * from articles' > ${WORKDIR}/otus.articles.txt

read -r -p "Остановить percona-server и удалить данные?: [y/N]" -n 1 answer
if [ "${answer}" == "y" ]; then
  docker stop percona-server
  sudo rm -rf ${DATA_DIR}/*
fi

