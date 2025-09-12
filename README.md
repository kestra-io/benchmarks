# benchmarks

- Configuration 1: standalone OSS deployment using a Google Cloud **e2-standard-4** (4 vCPUs - 16 GB RAM) machine and a Postgres 16 database (4 vCPUs - 16GB RAM)
- Configuration 2: standalone EE deployment using a Google Cloud **e2-standard-4** (4 vCPUs - 16 GB RAM) machine, a Kafka 3.8 message broker (4 vCPUs - 16GB RAM), and an Elasticsearch 8.17.5 database (4 vCPUs - 16GB RAM)

## Configuration 1 - Installation

Prerequisites: 
- [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [Kestra Installation via Docker](https://kestra.io/docs/installation/docker)

Using the following `application.yaml` file:
```yaml
datasources:
  postgres:
    url: jdbc:postgresql://host:port/kestra
    driverClassName: org.postgresql.Driver
    username: kestra
    password: "<set_a_password_here>"
kestra:
  tutorial-flows:
    enabled: false
  server:
    basicAuth:
      username: "admin@localhost.dev"
      password: "<set_a_password_here>"
  repository:
    type: postgres
  storage:
    type: local
    local:
      basePath: "/app/storage"
  queue:
    type: postgres
  tasks:
    tmpDir:
      path: /tmp/kestra-wd/tmp
  url: http://localhost:8080/
```

Note that we apply a single optimization here: we configure Kafka partition count to 8 instead of the default of 16.
As we only benchmark with a standalone deployment, using by default such high number of partition count is counter-performant as it's designed to be used for a high number of consumer nodes.
Our default Kafka configuration is designed for large deployments, which is clearly not the case on a benchmark with a standalone node.

Start Kestra:
```shell
sudo docker run --pull=always --rm -it -p 8080:8080 --user=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp:/tmp \
  -v $PWD/application.yaml:/etc/config/application.yaml \
  kestra/kestra:latest server standalone --config /etc/config/application.yaml
```

## Configuration 2 - Installation

Prerequisites:
- [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [Kestra Installation via Docker](https://kestra.io/docs/installation/docker)

Using the following `application-ee.yaml` file:
```yaml
kestra:
  tutorial-flows:
    enabled: false
  server:
    basicAuth:
      username: john@doe.com
      password: "<set_a_password_here>"
  repository:
    type: elasticsearch
  storage:
    type: local
    local:
      basePath: "/app/storage"
  queue:
    type: kafka
  elasticsearch:
    defaults:
      indices:
        index.number_of_replicas: 1
    client:
      http-hosts: http://host:port
  kafka:
    client:
      properties:
        bootstrap.servers: host:port
    defaults:
      topic:
        partitions: 8
  tasks:
    tmpDir:
      path: /tmp/kestra-wd/tmp
  url: http://localhost:8080/
  encryption:
    secret-key: "<set_a_secret_key_here>"
  secret:
    type: elasticsearch
    elasticsearch:
      secret: "<set_a_secret_key_here>"
  ee:
    license:
      id: "<set_a_license_id_here>"
      key: "<set_a_license_key_here>"
```

Note that we apply a single optimization here: we configure Kafka partition count to 8 instead of the default of 16.
As we only benchmark with a standalone deployment, using by default such high number of partition count is counter-performant as it's designed to be used for a high number of consumer nodes.
Our default Kafka configuration is designed for large deployments, which is clearly not the case on a benchmark with a standalone node.

Start Kestra:
```shell
sudo docker run --pull=always --rm -it -p 8080:8080 --user=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp:/tmp \
  -v $PWD/application-ee.yaml:/etc/config/application.yaml \
  registry.kestra.io/docker/kestra-ee:v1.0 server standalone --config /etc/config/application.yaml
```

## Benchmarks
* [Simple flow](01%20-%20Simple%20flow)
* [Complex flow](02%20-%20Complex%20flow)
* [Big ForEach Loop](03%20-%20Big%20ForEach%20Loop)
* [Realtime trigger with a transformation](03%20-%20Realtime%20trigger%20with%20a%20transformation)