# Benchmark 01 - Simple flow

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

First, let's warmup our Kestra instance a little by starting executions during 3mn at a rate of 500 executions/mn:
```shell
echo "GET http://server:port/api/v1/executions/webhook/benchmarks/benchmark01/benchmark" | vegeta attack -rate=500/m -duration 3m > result.gob
```

Then, generate load at your expected executions per second, for example, again at 500 executions/mn, during 5mn:
```shell
echo "GET http://server:port/api/v1/executions/webhook/benchmarks/benchmark01/benchmark" | vegeta attack -rate=500/m -duration 5m > result.gob
```

Finally, record the average execution time of your executions.
You can approximate that by looking at the execution list inside the UI and approximate the duration of the most recent ones or execute a query directly on the database.

Here is the query on JDBC:
```sql
select avg(state_duration) from executions;
```

Here is the query on Elasticsearch (Kibana style):
```json
POST /kestra_executions/_search
{
    "query": {
        "match_all": {}
    },
    "size": 0,
    "aggs": {
      "avg_dration": {
        "avg": {
            "field": "state.duration"
        }
      }
    }
}
```

## Cleaning

Between each load generation, it's better to delete all executions to avoid increasing the size of the database.

Here is the query on JDBC:
```sql
delete from executions;
```

Here is the query on Elasticsearch (Kibana style):
```json
POST /kestra_executions/_delete_by_query
{
    "query": {
        "match_all": {}
    }
}
```