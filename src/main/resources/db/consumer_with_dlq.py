import json
from confluent_kafka import Consumer, Producer, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic
import time
import sys

# ================== КОНФИГУРАЦИЯ ==================
BOOTSTRAP_SERVERS = "localhost:9092"          # внешний listener из docker-compose
GROUP_ID = "simple-consumer-group-with-retry"
MAIN_TOPIC = "simple"
RETRY_TOPICS = ["FirstError", "SecondError"]
DLQ_TOPIC = "DLQ"
MAX_RETRIES = 3                               # после 3-го падения → DLQ

TOPICS_TO_SUBSCRIBE = [MAIN_TOPIC] + RETRY_TOPICS

# Настройки producer (для отправки в error-топики)
producer_conf = {
    'bootstrap.servers': BOOTSTRAP_SERVERS,
    'client.id': 'retry-producer'
}
producer = Producer(producer_conf)


def delivery_report(err, msg):
    if err is not None:
        print(f"Delivery failed: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}]")

# ================== ОСНОВНАЯ ЛОГИКА ==================
def get_retry_count(headers):
    """Извлекаем retry-count из headers"""
    if not headers:
        return 0
    for key, value in headers:
        if key == "retry-count":
            return int(value.decode('utf-8'))
    return 0

def add_retry_header(headers, new_count):
    """Добавляем/обновляем заголовок retry-count"""
    if headers is None:
        headers = []
    # Удаляем старый, если есть
    headers = [h for h in headers if h[0] != "retry-count"]
    headers.append(("retry-count", str(new_count).encode('utf-8')))
    return headers

def process_message(msg):
    """←←← ТВОЯ РЕАЛЬНАЯ ОБРАБОТКА ЗДЕСЬ ←←←"""
    print(f"Processing message from {msg.topic()} | key={msg.key()} | retry={get_retry_count(msg.headers())}")

    data = json.loads(msg.value().decode('utf-8'))
    raise Exception("Test error - simulating failure")

    print("✅ Успешно обработано")
    return True

def send_to_next_topic(msg, current_retry):
    next_retry = current_retry + 1
    headers = add_retry_header(msg.headers(), next_retry)

    if next_retry >= MAX_RETRIES:
        target_topic = DLQ_TOPIC
        print(f"🚨 {current_retry+1}-й ретрай провалился → отправляем в DLQ")
    elif next_retry == 1:
        target_topic = "FirstError"
        print(f"⚠️ 1-й ретрай → FirstError")
    else:
        target_topic = "SecondError"
        print(f"⚠️ 2-й ретрай → SecondError")

    producer.produce(
        topic=target_topic,
        key=msg.key(),
        value=msg.value(),
        headers=headers,
        callback=delivery_report
    )
    producer.flush()

# ================== CONSUMER ==================
consumer_conf = {
    'bootstrap.servers': BOOTSTRAP_SERVERS,
    'group.id': GROUP_ID,
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False,      # ручной коммит
    'max.poll.interval.ms': 300000,   # 5 минут
}

consumer = Consumer(consumer_conf)
consumer.subscribe(TOPICS_TO_SUBSCRIBE)

print(f"🚀 Consumer запущен. Подписан на: {TOPICS_TO_SUBSCRIBE}")

try:
    while True:
        msg = consumer.poll(1.0)

        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                continue
            print(f"Consumer error: {msg.error()}")
            continue

        try:
            success = process_message(msg)
            if success:
                consumer.commit(msg)          # успех → коммитим
                continue
        except Exception as e:
            print(f"❌ Ошибка обработки: {e}")
            current_retry = get_retry_count(msg.headers())
            send_to_next_topic(msg, current_retry)
            consumer.commit(msg)              # в любом случае коммитим оригинал

except KeyboardInterrupt:
    print("👋 Остановка consumer")
finally:
    consumer.close()
    producer.flush()