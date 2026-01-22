URL=""
ES_URL=""

echo "Starting benchmark 1"
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
  echo "GET $URL/api/v1/main/executions/webhook/benchmarks/benchmark01/benchmark" | vegeta attack -rate=${load}/m -duration ${duration} > /tmp/result.go
  tearDown
}

echo "Warmup run for 5mn"
echo "GET $URL/api/v1/main/executions/webhook/benchmarks/benchmark01/benchmark" | vegeta attack -rate=250/m -duration 5m > /tmp/result.go
tearDown

run 1 250 3m
run 2 500 3m
run 3 1000 3m
run 4 1500 3m
run 5 2000 3m
run 6 2500 3m
run 7 3000 3m
run 8 3500 3m
run 9 4000 3m
run 10 4500 3m