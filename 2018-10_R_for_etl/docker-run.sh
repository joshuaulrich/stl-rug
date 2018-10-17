#!/usr/bin/env sh

# Try and stop/remove containers from previous runs
docker container stop pg > /dev/null && docker container rm pg > /dev/null

# Launch DB container
docker container run \
    -d \
    -p 5432:5432 \
    -e POSTGRES_USER="postgres" \
    -e POSTGRES_PASSWORD="postgres" \
    -v pg_data:/var/lib/postgresql/data/ \
    --name pg \
    postgres:alpine
