0)
SHOW TABLES;

1)
curl -X POST http://localhost:8080/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "eventType": "VISIT_STARTED",
    "eventTime": "2026-04-06T10:00:00",
    "metadata": {
      "branchId": 1,
      "trainerId": 10
    }
  }'

  curl -X POST http://localhost:8080/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "eventType": "VISIT_ENDED",
    "eventTime": "2026-04-06T11:30:00",
    "metadata": {
      "branchId": 1
    }
  }'

  curl -X POST http://localhost:8080/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 2,
    "eventType": "USER_SUBSCRIPTION_RENEWED",
    "eventTime": "2026-04-06T09:00:00",
    "metadata": {
      "plan": "monthly"
    }
  }'

SELECT * FROM events ORDER BY event_time DESC;

SELECT count()
FROM events
WHERE event_type = 'VISIT_STARTED';

SELECT toDate(event_time) AS date, count()
FROM events
WHERE event_type = 'VISIT_STARTED'
GROUP BY date;

SELECT user_id, count() AS visits
FROM events
WHERE event_type = 'VISIT_STARTED'
GROUP BY user_id;

SELECT count()
FROM events
WHERE event_type = 'USER_SUBSCRIPTION_RENEWED';

SELECT * FROM visits_daily ORDER BY date DESC;
SELECT * FROM subscriptions_stats ORDER BY date DESC;

SHOW CREATE TABLE events;

2)
DESCRIBE TABLE analytics_events;

SELECT * FROM analytics_events;

SELECT
    partition,
    count()
FROM system.parts
WHERE table = 'analytics_events'
  AND active = 1
GROUP BY partition;