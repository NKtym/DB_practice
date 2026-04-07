CREATE TABLE analytics_events_dedup
(
    event_id UUID,
    event_time DateTime64(3),
    event_date Date MATERIALIZED toDate(event_time),
    event_type LowCardinality(String),
    entity_type LowCardinality(String),
    entity_id UInt64,
    client_id Nullable(UInt64),
    employee_id Nullable(UInt64),
    product_id Nullable(UInt64),
    slot_id Nullable(UInt64),
    zone_id Nullable(UInt64),
    transaction_id Nullable(UInt64),
    amount Decimal(12, 2) DEFAULT 0,
    quantity UInt32 DEFAULT 1,
    payment_type Nullable(String),
    source String DEFAULT 'sport_center',
    created_at DateTime DEFAULT now(),
    metadata String
)
ENGINE = ReplacingMergeTree(created_at)
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_id);

INSERT INTO analytics_events_dedup
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
    created_at,
    metadata
)
SELECT
    event_id,
    argMax(event_time, created_at)        AS event_time,
    argMax(event_type, created_at)        AS event_type,
    argMax(entity_type, created_at)       AS entity_type,
    argMax(entity_id, created_at)         AS entity_id,
    argMax(client_id, created_at)         AS client_id,
    argMax(employee_id, created_at)       AS employee_id,
    argMax(product_id, created_at)        AS product_id,
    argMax(slot_id, created_at)           AS slot_id,
    argMax(zone_id, created_at)           AS zone_id,
    argMax(transaction_id, created_at)    AS transaction_id,
    argMax(amount, created_at)            AS amount,
    argMax(quantity, created_at)          AS quantity,
    argMax(payment_type, created_at)      AS payment_type,
    argMax(source, created_at)            AS source,
    max(created_at)                       AS created_at,
    argMax(metadata, created_at)          AS metadata
FROM analytics_events
GROUP BY event_id;