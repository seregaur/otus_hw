## Результат sysbench c подсунутым конфигом `my-custom-params.cnf`
```
sysbench 1.0.18 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 5
Initializing random number generator from current time


Initializing worker threads...

Threads started!

SQL statistics:
    queries performed:
        read:                            103180
        write:                           7446
        other:                           36768
        total:                           147394
    transactions:                        7367   (735.99 per sec.)
    queries:                             147394 (14725.16 per sec.)
    ignored errors:                      3      (0.30 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.0076s
    total number of events:              7367

Latency (ms):
         min:                                    3.16
         avg:                                    6.79
         max:                                   26.81
         95th percentile:                       13.46
         sum:                                49992.65

Threads fairness:
    events (avg/stddev):           1473.4000/5.00
    execution time (avg/stddev):   9.9985/0.00
```