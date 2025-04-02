# Benchmark -  Simple flow with a webhook

Here is the flow YAML:

```yaml
namespace: company.team

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

This flow contains two tasks that should execute realy quickly, the goal is to benchamrk the Kestra Executor not the task itself so we want them to be as quick as possible.

To benchmark this flow, we will use the Vegeta load tester which is a command line tool capable to put load on an HTTP URL at a constant rate.
Vegeta will be used from an external machine to avoid any potential interraction between the load testing tool and the machine executing Kestra.

First, let's warn ou Kestra instance a little by starting executions during 1mn at a rate of 1 executions/s:
```shell
echo "GET http://server:port/api/v1/executions/webhook/company.team/benchmark01/benchmark" | vegeta attack -rate=1/s -duration 60s > result-1.gob
```

Then, generate a load at your expected executions per second, for example:
```shell
echo "GET http://server:port/api/v1/executions/webhook/company.team/benchmark01/benchmark" | vegeta attack -rate=10/s -duration 60s > result-10.gob
```