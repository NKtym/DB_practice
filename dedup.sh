#!/bin/bash

CONTAINER_NAME=clickhouse
SQL_FILE=src/main/resources/db/dedup_clickhouse.sql

echo "Starting ClickHouse deduplication..."

docker exec -i $CONTAINER_NAME clickhouse-client < $SQL_FILE

echo "Deduplication finished"