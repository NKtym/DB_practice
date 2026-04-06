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