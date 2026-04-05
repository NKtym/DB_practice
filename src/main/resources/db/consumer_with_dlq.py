import json
from confluent_kafka import Consumer, Producer, KafkaError
import time
import random  # для симуляции ошибок

# ================== КОНФИГУРАЦИЯ ==================
BOOTSTRAP_SERVERS = "localhost:9092"
GROUP_ID = "simple-consumer-group-with-retry"

MAIN_TOPIC = "simple"
RETRY_TOPICS = ["FirstError", "SecondError"]
DLQ_TOPIC = "DLQ"
MAX_RETRIES = 3

ALL_TOPICS = [MAIN_TOPIC] + RETRY_TOPICS

# ================== PRODUCER (для ретраев и DLQ) ==================
producer_conf = {
    'bootstrap.servers': BOOTSTRAP_SERVERS,
    'client.id': 'retry-producer',
    'acks': 'all',
    'retries': 5,
}

producer = Producer(producer_conf)


def delivery_report(err, msg):
    if err is not None:
        print(f"❌ Delivery failed to {msg.topic()}: {err}")
    else:
        retry = get_retry_count(msg.headers())
        print(f"✅ Sent to {msg.topic()} [retry={retry}]")


# ================== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ==================
def get_retry_count(headers):
    """Надёжно извлекает retry-count независимо от типа (str / bytes)"""
    if not headers:
        return 0
    for key, value in headers:
        # Приводим ключ к строке
        if isinstance(key, bytes):
            key = key.decode('utf-8', errors='ignore')
        if key == "retry-count":
            # Приводим значение к строке и в int
            if isinstance(value, bytes):
                value = value.decode('utf-8', errors='ignore')
            try:
                return int(value)
            except:
                return 0
    return 0


def add_retry_header(headers, new_count):
    """Добавляем/обновляем заголовок retry-count"""
    if headers is None:
        headers = []
    # Удаляем старый заголовок (на всякий случай)
    headers = [h for h in headers if h[0] not in (b"retry-count", "retry-count")]
    headers.append(("retry-count", str(new_count).encode('utf-8')))
    return headers


def process_message(msg):
    """Твоя бизнес-логика здесь"""
    current_retry = get_retry_count(msg.headers())
    print(f"Processing from {msg.topic()} | key={msg.key()} | retry={current_retry}")

    try:
        data = json.loads(msg.value().decode('utf-8'))
        event_type = data.get("eventType", "UNKNOWN")

        # === Здесь пиши свою реальную обработку ===
        # if event_type == "USER_SUBSCRIPTION_EXPIRED":
        #     ...

        # Симуляция ошибок для теста (убери или уменьши процент в продакшене)
        if random.random() < 0.5:   # 50% шанс ошибки
            raise Exception(f"Simulated failure for eventType={event_type}")

        print(f"✅ Успешно обработано: {event_type} (retry={current_retry})")
        return True

    except Exception as e:
        print(f"❌ Ошибка обработки: {e}")
        raise


def send_to_next_topic(msg, current_retry):
    next_retry = current_retry + 1
    headers = add_retry_header(msg.headers(), next_retry)

    if next_retry >= MAX_RETRIES:
        target_topic = DLQ_TOPIC
        print(f"🚨 Достигнуто максимальное количество ретраев ({MAX_RETRIES}) → DLQ")
    elif next_retry == 1:
        target_topic = "FirstError"
        print(f"⚠️ 1-й ретрай → FirstError")
    else:
        target_topic = "SecondError"
        print(f"⚠️ {next_retry}-й ретрай → SecondError")

    producer.produce(
        topic=target_topic,
        key=msg.key(),
        value=msg.value(),
        headers=headers,
        callback=delivery_report
    )
    producer.flush(timeout=5.0)


# ================== CONSUMER ==================
consumer_conf = {
    'bootstrap.servers': BOOTSTRAP_SERVERS,
    'group.id': GROUP_ID,
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False,
    'max.poll.interval.ms': 300000,
}

consumer = Consumer(consumer_conf)
consumer.subscribe(ALL_TOPICS)

print(f"🚀 Consumer запущен. Подписан на: {ALL_TOPICS}")
print(f"   MAX_RETRIES = {MAX_RETRIES} → DLQ: {DLQ_TOPIC}\n")

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
                consumer.commit(asynchronous=False)
        except Exception:
            # Ошибка → отправляем в следующий ретрай-топик / DLQ
            current_retry = get_retry_count(msg.headers())
            send_to_next_topic(msg, current_retry)
            consumer.commit(asynchronous=False)   # коммитим в любом случае

except KeyboardInterrupt:
    print("\n👋 Consumer остановлен пользователем")
finally:
    consumer.close()
    producer.flush()
    print("Consumer и Producer закрыты")