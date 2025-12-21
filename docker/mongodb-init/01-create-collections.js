db = db.getSiblingDB('sports_center');

print("📦 Создаем коллекции...");

// Создаем коллекции
db.createCollection("class_attendance", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["slot_id", "trainer_id", "zone_id", "date", "status"],
      properties: {
        slot_id: { bsonType: "string" },
        trainer_id: { bsonType: "string" },
        zone_id: { bsonType: "string" },
        date: { bsonType: "date" },
        status: { bsonType: "string", enum: ["PLANNED", "CANCELLED", "DONE"] }
      }
    }
  }
});

db.createCollection("trainer_statistics", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["trainer_id", "period", "trainer_name"],
      properties: {
        trainer_id: { bsonType: "string" },
        period: { bsonType: "string" },
        trainer_name: { bsonType: "string" }
      }
    }
  }
});

db.createCollection("daily_zone_occupancy", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["zone_id", "zone_name", "date"],
      properties: {
        zone_id: { bsonType: "string" },
        zone_name: { bsonType: "string" },
        date: { bsonType: "date" }
      }
    }
  }
});

// Создаем индексы для оптимизации запросов
print("🔍 Создаем индексы...");

// Индексы для class_attendance
db.class_attendance.createIndex({ "slot_id": 1 }, { unique: true });
db.class_attendance.createIndex({ "trainer_id": 1 });
db.class_attendance.createIndex({ "zone_id": 1 });
db.class_attendance.createIndex({ "date": 1 });
db.class_attendance.createIndex({ "status": 1 });
db.class_attendance.createIndex({ "attendance_rate": 1 });
db.class_attendance.createIndex({ "date": 1, "trainer_id": 1 });
db.class_attendance.createIndex({ "date": 1, "zone_id": 1 });

// Индексы для trainer_statistics
db.trainer_statistics.createIndex({ "trainer_id": 1 });
db.trainer_statistics.createIndex({ "period": 1 });
db.trainer_statistics.createIndex({ "rating": -1 });
db.trainer_statistics.createIndex({ "trainer_id": 1, "period": 1 }, { unique: true });

// Индексы для daily_zone_occupancy
db.daily_zone_occupancy.createIndex({ "zone_id": 1 });
db.daily_zone_occupancy.createIndex({ "date": 1 });
db.daily_zone_occupancy.createIndex({ "zone_name": 1 });
db.daily_zone_occupancy.createIndex({ "occupancy_rate": -1 });
db.daily_zone_occupancy.createIndex({ "date": 1, "zone_id": 1 }, { unique: true });

print("✅ Коллекции и индексы созданы успешно!");