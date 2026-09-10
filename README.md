# benchmarks

- Configuration 1: standalone OSS deployment using a Google Cloud **n2-standard-4** (4 vCPUs - 16 GB RAM) machine and a Postgres 16 database (4 vCPUs - 16GB RAM)
- Configuration 2: standalone EE deployment using a Google Cloud **n2-standard-4** (4 vCPUs - 16 GB RAM) machine, a RabbitMQ message broker (4 vCPUs - 16GB RAM), and a Pstgres 16 database (4 vCPUs - 16GB RAM)

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

Start Kestra:
```shell
sudo docker run --pull=always --rm -it -p 8080:8080 --user=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp:/tmp \
  -v $PWD/application.yaml:/etc/config/application.yaml \
  kestra/kestra server standalone --config /etc/config/application.yaml
```

## Configuration 2 - Installation

Prerequisites:
- [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [Kestra Installation via Docker](https://kestra.io/docs/installation/docker)

Using the following `application-ee.yaml` file:
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
      username: john@doe.com
      password: "<set_a_password_here>"
  repository:
    type: postgres
  storage:
    type: local
    local:
      basePath: "/app/storage"
  queue:
    type: amqp
    amqp:
    client:
      url: amqp://user:password@host:port/kestra
  tasks:
    tmpDir:
      path: /tmp/kestra-wd/tmp
  url: http://localhost:8080/
  encryption:
    secret-key: "<set_a_secret_key_here>"
  secret:
    type: jdbc
    jdbc:
      secret: "<set_a_secret_key_here>"
  ee:
    license:
      id: "<set_a_license_id_here>"
      key: "<set_a_license_key_here>"
```

Start Kestra:
```shell
sudo docker run --pull=always --rm -it -p 8080:8080 --user=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /tmp:/tmp \
  -v $PWD/application-ee.yaml:/etc/config/application.yaml \
  registry.kestra.io/docker/kestra-ee server standalone --config /etc/config/application.yaml
```

## Benchmarks
* [Simple flow](01%20-%20Simple%20flow)
* [Complex flow](02%20-%20Complex%20flow)
* [Big ForEach Loop](03%20-%20Big%20ForEach%20Loop)
* [Realtime trigger with a transformation](03%20-%20Realtime%20trigger%20with%20a%20transformation)