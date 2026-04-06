#!/bin/bash

echo "Initializing ClickHouse..."

docker exec -i clickhouse clickhouse-client \
  --user default \
  --password changeme \
  < src/main/resources/db/init-clickhouse.sql

echo "ClickHouse initialized"