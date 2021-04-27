./start_nodes.sh

./mongo-cmd.sh mongo --host RS1-DB1 --port 27018
rs.initiate({"_id" : "RS1", members : [{"_id" : 0, priority : 3, host : "RS1-DB1:27018"},{"_id" : 1, host : "RS1-DB2:27018"},{"_id" : 2, host : "RS1-DB3:27018", arbiterOnly : true}]});
./mongo-cmd.sh mongo --host RS2-DB1 --port 27018
rs.initiate({"_id" : "RS2", members : [{"_id" : 0, priority : 3, host : "RS2-DB1:27018"},{"_id" : 1, host : "RS2-DB2:27018"},{"_id" : 2, host : "RS2-DB3:27018", arbiterOnly : true}]});
./mongo-cmd.sh mongo --host RS3-DB1 --port 27018
rs.initiate({"_id" : "RS3", members : [{"_id" : 0, priority : 3, host : "RS3-DB1:27018"},{"_id" : 1, host : "RS3-DB2:27018"},{"_id" : 2, host : "RS3-DB3:27018", arbiterOnly : true}]});
./mongo-cmd.sh mongo --host CONF1 --port 27019
rs.initiate({"_id" : "RSconf", configsvr: true, members : [{"_id" : 0, priority : 3, host : "CONF1:27019"},{"_id" : 1, host : "CONF2:27019"},{"_id" : 2, host : "CONF3:27019"}]});

./start_mongos.sh

Тут проходит примерно минута, пока ноды обнюхаются

Подцепился к mongos и добавил шарды 
./mongo-cmd.sh mongo --host MONGO_CLUSTER1

sh.addShard("RS1/RS1-DB1:27018,RS1-DB2:27018,RS1-DB3:27018")
sh.addShard("RS2/RS2-DB1:27018,RS2-DB2:27018,RS2-DB3:27018")
sh.addShard("RS3/RS3-DB1:27018,RS3-DB2:27018,RS3-DB3:27018")

mongos> sh.status()
```
--- Sharding Status ---
sharding version: {
"_id" : 1,
"minCompatibleVersion" : 5,
"currentVersion" : 6,
"clusterId" : ObjectId("6087d846ebf88edf6c41d7f3")
}
shards:
{  "_id" : "RS1",  "host" : "RS1/RS1-DB1:27018,RS1-DB2:27018",  "state" : 1 }
{  "_id" : "RS2",  "host" : "RS2/RS2-DB1:27018,RS2-DB2:27018",  "state" : 1 }
{  "_id" : "RS3",  "host" : "RS3/RS3-DB1:27018,RS3-DB2:27018",  "state" : 1 }
active mongoses:
"4.4.5" : 2
autosplit:
Currently enabled: yes
balancer:
Currently enabled:  yes
Currently running:  no
Failed balancer rounds in last 5 attempts:  0
Migration Results for the last 24 hours:
No recent migrations
databases:
{  "_id" : "config",  "primary" : "config",  "partitioned" : true }
```

Почистил за собой

./stop_all.sh

