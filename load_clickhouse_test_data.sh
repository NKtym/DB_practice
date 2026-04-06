#!/usr/bin/env bash
set -euo pipefail

INPUT_FILE="${1:-./clickhouse_test_data.tsv}"
TABLE="analytics_events"

if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Input file not found: $INPUT_FILE" >&2
  exit 1
fi

echo "Waiting for ClickHouse..."
until docker exec clickhouse clickhouse-client --query="SELECT 1" >/dev/null 2>&1; do
  sleep 2
done

echo "Копируем файл внутрь контейнера..."
docker cp "$INPUT_FILE" clickhouse:/tmp/data_for_insert.tsv

echo "Loading $INPUT_FILE into $TABLE ..."

docker exec clickhouse bash -c '
  clickhouse-client --query "
    INSERT INTO '"$TABLE"'
    (
      event_id,
      event_time,
      event_type,
      entity_type,
      entity_id,
      client_id,
      employee_id,
      product_id,
      slot_id,
      zone_id,
      transaction_id,
      amount,
      quantity,
      payment_type,
      source,
      metadata
    )
    SETTINGS async_insert=0, input_format_parallel_parsing=0
    FORMAT TabSeparatedWithNames
  " < /tmp/data_for_insert.tsv
'

echo "Load finished."
echo "Row count:"
docker exec -it clickhouse clickhouse-client --query="SELECT count() AS rows FROM $TABLE"

docker exec clickhouse rm -f /tmp/data_for_insert.tsv 2>/dev/null || true