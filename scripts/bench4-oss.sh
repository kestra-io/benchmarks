URL=""
DB_HOST=""
DB_PORT=""
DB_NAME=""
DB_USER=""
KAFKA_CONTAINER=""

if [[ -v PGPASSWORD ]]; then
    echo "Starting benchmark 4"
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
  local label=$2
  local load=$3
  local duration=$4
  local payload=$5
  local records=$6
  local throughput=$7
  echo "Run $num: $label $load exec/mn for $duration"
  sudo docker exec -ti $KAFKA_CONTAINER /opt/kafka/bin/kafka-producer-perf-test.sh --topic test_kestra --payload-file /opt/kafka/bin/products-$payload.json --num-records $records --throughput $throughput --producer-props bootstrap.servers=$URL
  tearDown
}

echo "Warmup run for 5mn"
sudo docker exec -ti KAFKA_CONTAINER /opt/kafka/bin/kafka-producer-perf-test.sh --topic test_kestra --payload-file /opt/kafka/bin/products-1.json --num-records 2400 --throughput 8 --producer-props bootstrap.servers=$URL
tearDown

run 1 "small-sized messages" 500 3mn 1 1440 8
run 2 "small-sized messages" 1000 3mn 1 2880 16
run 3 "small-sized messages" 1500 3mn 1 4320 24
run 4 "small-sized messages" 2000 3mn 1 5760 32

run 5 "medium-sized messages" 500 3mn 10 1440 8
run 6 "medium-sized messages" 750 3mn 10 2160 12
run 7 "medium-sized messages" 1000 3mn 10 2880 16
run 8 "medium-sized messages" 1250 3mn 10 3600 20
run 9 "medium-sized messages" 1500 3mn 10 4320 24

run 10 "large-sized messages" 250 3mn 100 720 4
run 11 "large-sized messages" 375 3mn 100 1080 6
run 12 "large-sized messages" 500 3mn 100 1440 8
run 13 "large-sized messages" 625 3mn 100 1800 10