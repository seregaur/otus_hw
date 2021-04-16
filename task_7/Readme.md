# Домашнее задание к занятию 19 "Внутренняя архитектура СУБД MySQL "

## Файлы:
- `docker-compose.yml` - манифест для docker-compose
- `init.sql` - скрипт создания БД
- `my-custom-params.cnf` - файл конфига для mysql

## Отчет

- запустил контейнер с mysql
```
docker-compose up -d
```
- подготовил `sysbench`
```
sysbench \
    --mysql-host=127.0.0.1 \
    --mysql-port=3309 \
    --mysql-user=root \
    --mysql-password=12345 \
    --db-driver=mysql \
    --mysql-db=otus \
    --table_size=1000000 --tables=10 --threads=5 \
    /usr/share/sysbench/oltp_read_write.lua prepare
```
- запустил `sysbench`
```
sysbench \
    --mysql-host=127.0.0.1 \
    --mysql-port=3309 \
    --mysql-user=root \
    --mysql-password=12345 \
    --db-driver=mysql \
    --mysql-db=otus \
    --table_size=10000000 --tables=10 --threads=5 \
    /usr/share/sysbench/oltp_read_write.lua run
```
- добавил кастомный сконфиг, перезапустил контейнер 
```
sudo cp my-custom-params.cnf ./custm.conf/
docker-compose down -v && docker-compose up -d
```
- запустил `sysbench` с теми же параметрами