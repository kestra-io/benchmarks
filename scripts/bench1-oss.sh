URL=
DB_HOST=
DB_PORT=
DB_NAME=
DB_USER=

if [[ -v PGPASSWORD ]]; then
    echo "Starting benchmark 1"
    echo "--------------------"
    echo ""
else
    echo "Missing PGPASSWORD env variable to access the database"
    exit 1
fi

tearDown() {
  sleep 30
  echo "Result (ms)"
  psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -t -c "select avg(state_duration)::integer from executions where namespace = 'benchmarks'"
  echo "Deleting created execution"
  psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -t -c "delete from executions where namespace  = 'benchmarks'"
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

echo "Warmup run for 5m"
echo "GET $URL/api/v1/main/executions/webhook/benchmarks/benchmark01/benchmark" | vegeta attack -rate=250/m -duration 5m > /tmp/result.go
tearDown

run 1 250 3m
run 2 500 3m
run 3 1000 3m
run 4 1500 3m
run 5 2000 3m