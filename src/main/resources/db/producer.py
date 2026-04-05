import json
import subprocess
import time
import uuid
import random
from datetime import datetime, timezone, timedelta

CONTAINER_NAME = "kafka1"
TOPIC = "simple"
BOOTSTRAP_SERVER = "kafka1:19092"

EVENT_TYPES = [
    "USER_SUBSCRIPTION_EXPIRED",
    "USER_SUBSCRIPTION_RENEWED",
    "VISIT_STARTED",
    "VISIT_ENDED"
]

def generate_id(prefix):
    return f"{prefix}_{uuid.uuid4().hex[:10]}"

def iso_now():
    return datetime.now(timezone.utc).isoformat()

def random_past_time():
    now = datetime.now(timezone.utc)
    past = now - timedelta(minutes=random.randint(1, 60))
    return past.isoformat()

def build_subscription_event(event_type):
    user_id = generate_id("user")
    subscription_id = generate_id("sub")

    payload = {
        "userId": user_id,
        "subscriptionId": subscription_id,
    }

    if event_type == "USER_SUBSCRIPTION_EXPIRED":
        payload["expiredAt"] = iso_now()
    elif event_type == "USER_SUBSCRIPTION_RENEWED":
        payload["renewedAt"] = iso_now()

    return {
        "eventId": generate_id("evt"),
        "eventType": event_type,
        "entityId": subscription_id,
        "timestamp": int(time.time() * 1000),
        "source": "subscription-service",
        "payload": payload,
        "version": 1
    }

def build_visit_event(event_type):
    user_id = generate_id("user")
    subscription_id = generate_id("sub")
    visit_id = generate_id("visit")
    slot_id = generate_id("slot")

    event_time = random_past_time()

    return {
        "eventId": generate_id("evt"),
        "eventType": event_type,
        "entityId": subscription_id,
        "timestamp": int(time.time() * 1000),
        "source": "access-control-service",
        "payload": {
            "userId": user_id,
            "subscriptionId": subscription_id,
            "visitId": visit_id,
            "time": event_time,
            "slot_id": slot_id
        },
        "version": 1
    }

def build_message():
    event_type = random.choice(EVENT_TYPES)
    if event_type in ["USER_SUBSCRIPTION_EXPIRED", "USER_SUBSCRIPTION_RENEWED"]:
        return build_subscription_event(event_type)
    else:
        return build_visit_event(event_type)

def send_to_kafka(message):
    json_message = json.dumps(message)
    key = message["entityId"]

    cmd = [
        "docker", "exec", "-i", CONTAINER_NAME,
        "kafka-console-producer",
        "--broker-list", BOOTSTRAP_SERVER,
        "--topic", TOPIC,
        "--property", "parse.key=true",
        "--property", "key.separator=:"
    ]

    process = subprocess.Popen(
        cmd,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    kafka_input = f"{key}:{json_message}\n"
    stdout, stderr = process.communicate(kafka_input)

    if process.returncode == 0:
        print(f"✅ Sent to {TOPIC} | key={key} | eventType={message['eventType']}")
    else:
        print(f"❌ Error sending message: {stderr}")

if __name__ == "__main__":
    print("🚀 Producer запущен. Отправляем сообщения в основной топик 'simple'")
    count = 0
    try:
        while True:
            msg = build_message()
            send_to_kafka(msg)
            count += 1
            if count >= 10:
                print("✅ Отправлено 10 сообщений. Завершаем.")
                break
            time.sleep(0.5)  # небольшая пауза между сообщениями
    except KeyboardInterrupt:
        print("\n👋 Producer остановлен")