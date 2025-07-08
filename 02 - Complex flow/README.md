# Benchmark 02 - Complex flow

## The flow

Here is the flow YAML:

```yaml
id: benchmark02
namespace: benchmarks

inputs:
  - id: condition
    type: BOOL
    defaults: true

triggers:
  - id: webhook
    type: io.kestra.plugin.core.trigger.Webhook
    key: benchmark

tasks:
  - id: if1
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.condition}}"
    then:
      - id: hello-true-1
        type: io.kestra.plugin.core.log.Log
        message: Hello True 1
    else:
      - id: hello-false-1
        type: io.kestra.plugin.core.log.Log
        message: Hello False 1
  - id: if2
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.condition}}"
    then:
      - id: hello-true-2
        type: io.kestra.plugin.core.log.Log
        message: Hello True 2
    else:
      - id: hello-false-2
        type: io.kestra.plugin.core.log.Log
        message: Hello False 2
  - id: if1-3
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.condition}}"
    then:
      - id: hello-true-3
        type: io.kestra.plugin.core.log.Log
        message: Hello True 3
    else:
      - id: hello-false-3
        type: io.kestra.plugin.core.log.Log
        message: Hello False 3
  - id: if4
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.condition}}"
    then:
      - id: hello-true-4
        type: io.kestra.plugin.core.log.Log
        message: Hello True 4
    else:
      - id: hello-false-4
        type: io.kestra.plugin.core.log.Log
        message: Hello False 4
  - id: if5
    type: io.kestra.plugin.core.flow.If
    condition: "{{inputs.condition}}"
    then:
      - id: hello-true-5
        type: io.kestra.plugin.core.log.Log
        message: Hello True 5
    else:
      - id: hello-false-5
        type: io.kestra.plugin.core.log.Log
        message: Hello False 5
```

This flow will create 10 task runs (5 `If` and 5 `Log`). 
This is an example of a flow with a lot of orchestration tasks in it, so it will put pressure on the Kestra Executor.

## Benchmarking

To benchmark this flow, we will use the Vegeta load generator which is a command line tool capable to put load on an HTTP URL at a constant rate.
Vegeta will be used from an external machine to avoid any potential interaction between the load testing tool and the machine executing Kestra.

First, let's warmup our Kestra instance a little by starting executions during 3mn at a rate of 100 executions/mn:
```shell
echo "GET http://server:port/api/v1/executions/webhook/benchmarks/benchmark02/benchmark" | vegeta attack -rate=100/m -duration 3m > result.gob
```

Then, generate load at your expected executions per second, for example, again at 100 executions/mn, during 5mn:
```shell
echo "GET http://server:port/api/v1/executions/webhook/benchmarks/benchmark02/benchmark" | vegeta attack -rate=100/m -duration 5m > result.gob
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