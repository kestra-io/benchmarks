# Benchmark 02 - Complex flow

## The flow

Here is the flow YAML:

```yaml
id: benchmark02
namespace: benchmarks

tasks:
  - id: foreach
    type: io.kestra.plugin.core.flow.ForEach
    values: "{{range(1, 100)}}"
    concurrencyLimit: 0
    tasks:
      - id: output
        type: io.kestra.plugin.core.output.OutputValues
        values:
          some: value
```

This flow will create a lot of task runs. It will lead to a big execution context as it will create outputs for each task run that will then be merged in the execution context (for expression processing in tasks).

## Benchmarking

To test it, launch it 3 to 5 times and record the better execution time.
You need to run it multiple times to warmup Kestra to peak performance.

## Cleaning

TODO 