CREATE TABLE IF NOT EXISTS events
(
    user_id UInt64,
    event_type String,
    event_time DateTime,
    metadata String
)
ENGINE = MergeTree()
ORDER BY (user_id, event_time);

ALTER TABLE events
MODIFY TTL event_time + INTERVAL 30 DAY;

CREATE TABLE IF NOT EXISTS visits_daily
(
    date Date,
    visits UInt64
)
ENGINE = SummingMergeTree()
ORDER BY date;

CREATE TABLE IF NOT EXISTS subscriptions_stats
(
    date Date,
    renewals UInt64
)
ENGINE = SummingMergeTree()
ORDER BY date;

INSERT INTO visits_daily
SELECT
    toDate(event_time) AS date,
    count() AS visits
FROM events
WHERE event_type = 'VISIT_STARTED'
GROUP BY date;

INSERT INTO subscriptions_stats
SELECT
    toDate(event_time) AS date,
    count() AS renewals
FROM events
WHERE event_type = 'USER_SUBSCRIPTION_RENEWED'
GROUP BY date;

CREATE TABLE IF NOT EXISTS analytics_events
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
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_time)
ORDER BY (event_time, event_type, entity_type, entity_id);

INSERT INTO analytics_events
(
    event_id,
    event_time,
    event_type,
    entity_type,
    entity_id,
    client_id,
    amount,
    payment_type,
    metadata
)
VALUES
(
    generateUUIDv4(),
    now(),
    'transaction_created',
    'transaction',
    1,
    10,
    1500.00,
    'card',
    '{}'
);