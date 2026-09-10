# Benchmark 03 - Big Loop

## The flow

Here is the flow YAML:

```yaml
id: benchmark03
namespace: benchmarks

tasks:
  - id: foreach
    type: io.kestra.plugin.core.flow.Loop
    values: "{{range(1, 100)}}"
    concurrencyLimit: 0
    tasks:
      - id: output
        type: io.kestra.plugin.core.output.OutputValues
        values:
          some: value
```

NOTE: If using Kestra 1.x, you must replace `io.kestra.plugin.core.flow.Loop` by `io.kestra.plugin.core.flow.ForEach`.

In 1.x, this flow will create a lot of task runs. It will lead to a big execution context as it will create outputs for each task run that will then be merged in the execution context (for expression processing in tasks).

In 2.x, this flow will create only one task run in the main flow then run each iteration on a separate sub-executions so the main execution will not have a big execution context.

## Benchmarking

To test it, launch it 5 times and record the better execution time.
You need to run it multiple times to warmup Kestra to peak performance.

## Cleaning

You can delete manually the created executions to cleanup your benchmark environment.