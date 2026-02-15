#!/usr/bin/env python3
import os
import time
import json
import redis
import psycopg2
import psycopg2.extras

POSTGRES_USER = os.getenv("POSTGRES_USER", "appuser")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "secretpassword")
POSTGRES_DB = os.getenv("POSTGRES_DB", "appdb")
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "localhost")
POSTGRES_PORT = int(os.getenv("POSTGRES_PORT", "5433"))

REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

BATCH_SIZE = int(os.getenv("BATCH_SIZE", "1000"))
TTL_SECONDS = int(os.getenv("TTL_SECONDS", "3600"))
TOP_KEY_LIST = "top_clients_list"
TOP_TTL = 3600

def pg_connect():
    return psycopg2.connect(
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        cursor_factory=psycopg2.extras.DictCursor
    )

def redis_connect():
    return redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        decode_responses=True,
        socket_keepalive=True
    )

def load_clients():
    pg = pg_connect()
    r = redis_connect()

    cur = pg.cursor(name="csr_clients")
    cur.itersize = BATCH_SIZE
    cur.execute("""
        SELECT
            client_id::text,
            first_name,
            last_name,
            phone,
            registration_date::text,
            card_status::text
        FROM clients
    """)

    total = 0
    batch = []
    last_report = time.time()
    try:
        for row in cur:
            total += 1
            key = f"client:profile:{row['client_id']}"
            mapping = {
                "client_id": row["client_id"],
                "first_name": row["first_name"] or "",
                "last_name": row["last_name"] or "",
                "phone": row["phone"] or "",
                "registration_date": row["registration_date"] or "",
                "card_status": row["card_status"] or ""
            }
            batch.append((key, mapping))

            if len(batch) >= BATCH_SIZE:
                flush_batch(r, batch)
                batch.clear()

            if time.time() - last_report > 10:
                print(f"Loaded {total} clients...")
                last_report = time.time()

        if batch:
            flush_batch(r, batch)
        print(f"Finished loading {total} clients")
    finally:
        cur.close()
        pg.close()

def flush_batch(r, batch):
    backoff = 0.5
    for attempt in range(5):
        try:
            pipe = r.pipeline(transaction=False)
            for key, mapping in batch:
                pipe.hset(key, mapping=mapping)
                pipe.expire(key, TTL_SECONDS)
            pipe.execute()
            return
        except redis.exceptions.ConnectionError:
            time.sleep(backoff)
            backoff *= 2
            r = redis_connect()
    raise RuntimeError("Redis pipeline failed")

def update_top_clients():
    pg = pg_connect()
    r = redis_connect()
    cur = pg.cursor()
    try:
        cur.execute("""
            SELECT
                c.client_id,
                COALESCE(c.first_name,'') || ' ' || COALESCE(c.last_name,'') AS client_name,
                SUM(t.total_amount) AS total_spent,
                MAX(t.datatime) AS last_transaction_date,
                COUNT(*) AS tx_count
            FROM transactions t
            JOIN clients c ON c.client_id = t.client_id
            GROUP BY c.client_id, c.first_name, c.last_name
            ORDER BY SUM(t.total_amount) DESC
            LIMIT 10
        """)
        top = []
        for row in cur:
            top.append({
                "client_id": row[0],
                "client_name": row[1],
                "total_spent": float(row[2]),
                "last_transaction_date": str(row[3]),
                "tx_count": row[4]
            })

        r.delete(TOP_KEY_LIST)
        for client in top:
            r.rpush(TOP_KEY_LIST, json.dumps(client))
        r.expire(TOP_KEY_LIST, TOP_TTL)

        print(f"Top 10 clients list updated at {time.strftime('%Y-%m-%d %H:%M:%S')}")
    finally:
        cur.close()
        pg.close()

if __name__ == "__main__":
    print("Starting Redis loader...")
    while True:
        load_clients()
        update_top_clients()
        time.sleep(TOP_TTL)
