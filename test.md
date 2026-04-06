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

3)
SELECT count() FROM analytics_events;

SELECT
    entity_id,
    count() AS cnt
FROM analytics_events
GROUP BY entity_id
HAVING cnt > 1
ORDER BY cnt DESC
LIMIT 20;

SELECT
    toStartOfHour(event_time) AS hour,
    count() AS rows
FROM analytics_events
GROUP BY hour
ORDER BY hour;

SELECT
    event_date,
    count() AS rows
FROM analytics_events
GROUP BY event_date
ORDER BY event_date;

SELECT
    countDistinct(event_date) AS days_count,
    min(event_date) AS first_day,
    max(event_date) AS last_day
FROM analytics_events;

SELECT
    countDistinct(toStartOfWeek(event_time)) AS weeks_count
FROM analytics_events;

4)
Количество событий по дням - общая динамика нагрузки по дням
SELECT
    event_date,
    count() AS events
FROM analytics_events
WHERE event_time >= now() - INTERVAL 30 DAY
GROUP BY event_date
ORDER BY event_date;

Уникальные клиенты по дням - оценка дневного охвата пользователей
SELECT
    event_date,
    uniqExact(client_id) AS unique_clients
FROM analytics_events
WHERE client_id IS NOT NULL
GROUP BY event_date
ORDER BY event_date;

Сумма выручки по дням - динамика выручки
SELECT
    event_date,
    sum(amount) AS revenue
FROM analytics_events
WHERE amount > 0
GROUP BY event_date
ORDER BY event_date;

Активность по часам - часы пиковой нагрузки
SELECT
    toHour(event_time) AS hour,
    count() AS events
FROM analytics_events
WHERE event_time >= now() - INTERVAL 7 DAY
GROUP BY hour
ORDER BY hour;

Количество событий по типам - типы событий которые встречаются чаще всего
SELECT
    event_type,
    count() AS events
FROM analytics_events
GROUP BY event_type
ORDER BY events DESC;

Средний чек по типам событий - средняя денежная ценность разных сценарие
SELECT
    event_type,
    round(avg(amount), 2) AS avg_amount
FROM analytics_events
WHERE amount > 0
GROUP BY event_type
ORDER BY avg_amount DESC;

Топ клиентов по активности - самые активные пользователи
SELECT
    client_id,
    count() AS events
FROM analytics_events
WHERE client_id IS NOT NULL
GROUP BY client_id
ORDER BY events DESC
LIMIT 5;

Активность сотрудников - нагрузка на сотрудников
SELECT
    employee_id,
    count() AS events
FROM analytics_events
WHERE employee_id IS NOT NULL
GROUP BY employee_id
ORDER BY events DESC
LIMIT 10;

5)
SELECT
    event_date,
    event_type,
    entity_type,
    countMerge(events_state) AS events,
    round(sumMerge(revenue_state), 2) AS revenue,
    uniqExactMerge(unique_clients_state) AS unique_clients
FROM analytics_events_daily_agg
WHERE event_date >= today() - INTERVAL 30 DAY
GROUP BY
    event_date,
    event_type,
    entity_type
ORDER BY event_date DESC, events DESC;

6)