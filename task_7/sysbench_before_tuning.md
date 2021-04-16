## Результат sysbench на дефолтных настройках

```
sysbench 1.0.18 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 5
Initializing random number generator from current time


Initializing worker threads...

Threads started!

SQL statistics:
    queries performed:
        read:                            16226
        write:                           1155
        other:                           5785
        total:                           23166
    transactions:                        1152   (114.91 per sec.)
    queries:                             23166  (2310.77 per sec.)
    ignored errors:                      7      (0.70 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.0210s
    total number of events:              1152

Latency (ms):
         min:                                   14.54
         avg:                                   43.45
         max:                                  156.41
         95th percentile:                       68.05
         sum:                                50051.82

Threads fairness:
    events (avg/stddev):           230.4000/2.87
    execution time (avg/stddev):   10.0104/0.00
```