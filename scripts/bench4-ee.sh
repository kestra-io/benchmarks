URL=""
ES_URL=""
KAFKA_CONTAINER=""

echo "Starting benchmark 4"
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
sudo docker exec -ti $KAFKA_CONTAINER /opt/kafka/bin/kafka-producer-perf-test.sh --topic test_kestra --payload-file /opt/kafka/bin/products-1.json --num-records 2400 --throughput 8 --producer-props bootstrap.servers=$URL
tearDown

run 1 "small-sized messages" 500 3mn 1 1440 8
run 2 "small-sized messages" 1000 3mn 1 2880 16
run 3 "small-sized messages" 1500 3mn 1 4320 24
run 4 "small-sized messages" 2000 3mn 1 5760 32
run 5 "small-sized messages" 2500 3mn 1 7200 40
run 6 "small-sized messages" 3000 3mn 1 8640 48
run 7 "small-sized messages" 3500 3mn 1 10080 52
run 8 "small-sized messages" 4000 3mn 1 11520 60

run 9 "medium-sized messages" 500 3mn 10 1440 8
run 10 "medium-sized messages" 750 3mn 10 2160 12
run 11 "medium-sized messages" 1000 3mn 10 2880 16
run 12 "medium-sized messages" 1250 3mn 10 3600 20
run 13 "medium-sized messages" 1500 3mn 10 4320 24
run 14 "medium-sized messages" 1750 3mn 10 5040 28
run 15 "medium-sized messages" 2000 3mn 10 5760 32
run 16 "medium-sized messages" 2250 3mn 10 6480 36
run 17 "medium-sized messages" 2500 3mn 10 7920 40

run 18 "large-sized messages" 250 3mn 100 720 4
run 19 "large-sized messages" 375 3mn 100 1080 6
run 20 "large-sized messages" 500 3mn 100 1440 8
run 21 "large-sized messages" 625 3mn 100 1800 10
run 22 "large-sized messages" 750 3mn 100 2130 12