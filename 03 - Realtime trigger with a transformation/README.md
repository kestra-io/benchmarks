# Benchmark 03 - Realtime trigger with a transformation

## The flow

Here is the flow YAML:

```yaml
id: benchmark03
namespace: company.team

triggers:
  - id: kafka-logs
    type: io.kestra.plugin.kafka.RealtimeTrigger
    topic: test_kestra
    properties:
      bootstrap.servers: localhost:9092
    groupId: myGroup

tasks:
  - id: transform
    type: io.kestra.plugin.transform.jsonata.TransformValue
    from:  "{{trigger.value}}"
    expression: |
      $.{
        "order_id": order_id,
        "customer_name": first_name & ' ' & last_name,
        "address": address.city & ', ' & address.country,
        "total_price": $sum(items.(quantity * price_per_unit))
      }
  - id: hello
    type: io.kestra.plugin.core.output.OutputValues
    values:
      log: "{{outputs.transform.value}}"
```

This flow will be executed for each message in the `test_kestra` topic.
It will transform the message using JSONata and set it as output of a second task.

To trigger execution of this flow, you can use the `kafka-producer-perf-test.sh` script provided by the Kafka Docker image.

Here is an example JSON file to use as test input, it contains a single element to map, you can craft files with more elements to test messages of bigger size.

```json
[{ "order_id": "ABC123", "first_name": "John", "last_name": "Doe", "address": { "city": "Paris", "country": "France" }, "items": [{"product_id": "001","name": "Apple","quantity": 5,"price_per_unit": 0.5},{"product_id": "002","name": "Banana","quantity": 3,"price_per_unit": 0.3},{"product_id": "003","name": "Orange","quantity": 2,"price_per_unit": 0.4}]}]
```

Create a file in the machine that will launch the benchmark with the content of this file, here we call the file `test.json`.
You can find example files with 1, 10 and 100 product items in the [resources](resources) folder.

## Benchmarking

First, let's warmup our Kestra instance a little by starting executions during 1mn at a rate of 10 executions/s:

```shell
./kafka-producer-perf-test.sh --topic test_kestra --payload-file test.json \
  --num-records 600 --throughput 10 --producer-props bootstrap.servers=localhost:9092
```

Then, generate load at your expected executions per second, for example again at 10 executions/s:

```shell
./kafka-producer-perf-test.sh --topic test_kestra --payload-file test.json \
  --num-records 600 --throughput 10 --producer-props bootstrap.servers=localhost:9092
```

Finally, record the average execution time of your executions.
You can approximate that by looking at the execution list inside the UI and approximate the duration of the most recent ones.

## Cleaning

TODO 