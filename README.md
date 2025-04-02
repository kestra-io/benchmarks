# benchmarks

- Configuration 1: standalone deployment on an **e2-standard-4** (4CPU - 16GB) machine

## Configuration 1 - Installation
- Prerequisites: [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
- [Kestra Installation via Docker Compose](https://kestra.io/docs/installation/docker-compose)
- Start Kestra: `docker compose up -d`

## Benchmarks
* [Simple flow with a webhook](01%20-%20Simple%20flow%20with%20a%20webhook)
* [Complex flow](02%20-%20Complex%20flow)
* [Realtime trigger with a transformation](03%20-%20Realtime%20trigger%20with%20a%20transformation)