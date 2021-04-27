### Файлы
- [start_mongo.sh](start_mongo.sh) - запуск контейнера с сервером mongodb
- [stop_mongo.sh](stop_mongo.sh) - остановка контейнера с сервером mongodb
- [mongo-cmd.sh](mongo-cmd.sh) - обертка для выполнения утилит из docker образа mongo

### Отчет
1. Запустил mongodb и подключился
```
./start_mongo.sh   
./mongo-cmd.sh mongo --host mongo-srv1 --username=root --password=password
```

