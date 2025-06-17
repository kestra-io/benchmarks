# Benchmark 01 - Simple flow with a webhook

## The flow

Here is the flow YAML:

```yaml
id: benchmark01
namespace: benchmarks

triggers:
  - id: webhook
    type: io.kestra.plugin.core.trigger.Webhook
    key: benchmark

inputs:
  - id: name
    type: STRING
    defaults: World

tasks:
  - id: concatenate
    type: io.kestra.plugin.core.output.OutputValues
    values:
      message: Hello {{ inputs.name }}
  - id: hello
    type: io.kestra.plugin.core.log.Log
    message: "{{ outputs.concatenate.values.message }}"
```

This flow contains two tasks that should execute really quickly, the goal is to benchmark the Kestra Executor not the task itself so we want them to be as quick as possible.

## Benchmarking

To benchmark this flow, we will use the Vegeta load generator which is a command line tool capable to put load on an HTTP URL at a constant rate.
Vegeta will be used from an external machine to avoid any potential interaction between the load testing tool and the machine executing Kestra.

First, let's warmup our Kestra instance a little by starting executions during 1mn at a rate of 10 executions/s:
```shell
echo "GET http://server:port/api/v1/executions/webhook/benchmarks/benchmark01/benchmark" | vegeta attack -rate=10/s -duration 60s > result.gob
```

Then, generate load at your expected executions per second, for example, again at 10 executions/s:
```shell
echo "GET http://server:port/api/v1/executions/webhook/benchmarks/benchmark01/benchmark" | vegeta attack -rate=10/s -duration 60s > result.gob
```

Finally, record the average execution time of your executions.
You can approximate that by looking at the execution list inside the UI and approximate the duration of the most recent ones or execute a query directly on the database.

Between each load generation, it's better to delete all executions to avoid increasing the size of the database.

```sql
select avg(state_duration) from executions;
```

## Cleaning

Between each load generation, it's better to delete all executions to avoid increasing the size of the database.

```sql
delete from executions;
```

2 threads
---------
10 exec/s: 260ms
20 exec/s: 16s
30 exec/s: 50s
=> Kestra CPU utilization: 20%
=> BDD  CPU utilization: 70% max (certainly due to cold start in part)

4 threads
---------
10 exec/s: 240ms
20 exec/s: 3s
30 exec/s: 50s
=> Kestra CPU utilization: 40%
=> BDD  CPU utilization: 60% max

8 threads
---------
10 exec/s: 180ms
20 exec/s: 400ms
30 exec/s: 25s
=> Kestra CPU utilization: 40%
=> BDD  CPU utilization: ? max