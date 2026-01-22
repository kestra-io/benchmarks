URL=""
ES_URL=""

echo "Starting benchmark 2"
echo "--------------------"
echo ""

tearDown() {
  sleep 30
  echo "Result (ms)"
  curl -X POST -H "Content-Type: application/json" -d "@es-avg-execution.json" $ES_URL/kestra_executions/_search
  echo ""
  echo "Deleting created execution"
  curl -X POST -H "Content-Type: application/json" -d "@es-delete-execution.json" $ES_URL/kestra_executions/_delete_by_query
  echo ""
  echo ""
}

run() {
  local num=$1
  local load=$2
  local duration=$3
  echo "Run $num: $load exec/mn for $duration"
  echo "GET $URL/api/v1/main/executions/webhook/benchmarks/benchmark02/benchmark" | vegeta attack -rate=${load}/m -duration ${duration} > /tmp/result.go
  tearDown
}

echo "Warmup run for 5mn"
echo "GET $URL/api/v1/main/executions/webhook/benchmarks/benchmark02/benchmark" | vegeta attack -rate=100/m -duration 5m > /tmp/result.go
tearDown

run 1 100 3m
run 2 200 3m
run 3 300 3m
run 4 400 3m
run 5 500 3m
run 6 600 3m
run 7 700 3m
run 8 800 3m