3 ключевые метрики
Общее количество событий - сколько действий произошло за 30 дней
SELECT count() AS total_events
FROM analytics_events
WHERE event_time >= now() - INTERVAL 30 DAY;

Количество уникальных клиентов - популярность
SELECT uniqExact(coalesce(client_id, 0)) AS unique_clients
FROM analytics_events
WHERE event_time >= now() - INTERVAL 30 DAY;

Общая выручка - прибыль
SELECT sumIf(amount, amount > 0) AS total_revenue
FROM analytics_events
WHERE event_time >= now() - INTERVAL 30 DAY;

Сравнение сырых запросов и запросов через витрину
SELECT
    toDate(event_time) AS day,
    count() AS total_events,
    sumIf(amount, amount > 0) AS revenue,
    uniqExact(coalesce(client_id, 0)) AS unique_clients
FROM analytics_events
WHERE event_time >= now() - INTERVAL 30 DAY
GROUP BY day
ORDER BY day;

SELECT
    event_date AS day,
    countMerge(events_state) AS total_events,
    sumMerge(revenue_state) AS revenue,
    uniqExactMerge(unique_clients_state) AS unique_clients
FROM analytics_events_daily_agg
WHERE event_date >= today() - 30
GROUP BY day
ORDER BY day;

Аналитика:
Система активно используется и довольно популярная. За 30 дней зафиксировано 74 962 события.
Есть хорошая клиентская база. За тот же период найдено 601 уникальный клиент.
Бизнес-активность высокая. Общая выручка составила 85 879 825,52.