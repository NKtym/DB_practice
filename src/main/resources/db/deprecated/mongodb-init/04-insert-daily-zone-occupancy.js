db = db.getSiblingDB('sports_center');

print("🏋️ Заполняем daily_zone_occupancy...");

db.daily_zone_occupancy.insertMany([
  {
    zone_id: "550e8400-e29b-41d4-a716-446655440020",
    zone_name: "Зал А",
    zone_type: "GROUP_CLASS",
    date: ISODate("2025-09-23T00:00:00Z"),
    total_visits: 68,
    max_capacity: 80,
    occupancy_rate: 0.85,
    hourly_occupancy: [
      { hour: 8, occupancy_rate: 0.4, visits: 16 },
      { hour: 9, occupancy_rate: 0.9, visits: 18 },
      { hour: 10, occupancy_rate: 0.7, visits: 14 },
      { hour: 11, occupancy_rate: 0.6, visits: 12 },
      { hour: 12, occupancy_rate: 0.3, visits: 6 },
      { hour: 13, occupancy_rate: 0.2, visits: 4 },
      { hour: 14, occupancy_rate: 0.75, visits: 15 },
      { hour: 15, occupancy_rate: 0.8, visits: 16 },
      { hour: 16, occupancy_rate: 0.5, visits: 10 },
      { hour: 17, occupancy_rate: 0.9, visits: 18 },
      { hour: 18, occupancy_rate: 0.85, visits: 17 },
      { hour: 19, occupancy_rate: 0.7, visits: 14 },
      { hour: 20, occupancy_rate: 0.4, visits: 8 }
    ],
    peak_hours: [9, 17, 18],
    average_session_duration: 55,
    updated_at: ISODate("2025-09-23T21:00:00Z")
  },
  {
    zone_id: "550e8400-e29b-41d4-a716-446655440022",
    zone_name: "Тренажерный зал",
    zone_type: "GYM",
    date: ISODate("2025-09-23T00:00:00Z"),
    total_visits: 120,
    max_capacity: 150,
    occupancy_rate: 0.80,
    hourly_occupancy: [
      { hour: 6, occupancy_rate: 0.3, visits: 18 },
      { hour: 7, occupancy_rate: 0.6, visits: 36 },
      { hour: 8, occupancy_rate: 0.7, visits: 42 },
      { hour: 9, occupancy_rate: 0.5, visits: 30 },
      { hour: 10, occupancy_rate: 0.4, visits: 24 },
      { hour: 11, occupancy_rate: 0.3, visits: 18 },
      { hour: 12, occupancy_rate: 0.6, visits: 36 },
      { hour: 13, occupancy_rate: 0.5, visits: 30 },
      { hour: 14, occupancy_rate: 0.4, visits: 24 },
      { hour: 15, occupancy_rate: 0.7, visits: 42 },
      { hour: 16, occupancy_rate: 0.9, visits: 54 },
      { hour: 17, occupancy_rate: 0.95, visits: 57 },
      { hour: 18, occupancy_rate: 0.9, visits: 54 },
      { hour: 19, occupancy_rate: 0.8, visits: 48 },
      { hour: 20, occupancy_rate: 0.6, visits: 36 },
      { hour: 21, occupancy_rate: 0.4, visits: 24 }
    ],
    peak_hours: [16, 17, 18],
    average_session_duration: 75,
    updated_at: ISODate("2025-09-23T21:00:00Z")
  },
  {
    zone_id: "550e8400-e29b-41d4-a716-446655440023",
    zone_name: "Бассейн",
    zone_type: "POOL",
    date: ISODate("2025-09-23T00:00:00Z"),
    total_visits: 85,
    max_capacity: 100,
    occupancy_rate: 0.85,
    hourly_occupancy: [
      { hour: 7, occupancy_rate: 0.4, visits: 16 },
      { hour: 8, occupancy_rate: 0.6, visits: 24 },
      { hour: 9, occupancy_rate: 0.5, visits: 20 },
      { hour: 10, occupancy_rate: 0.7, visits: 28 },
      { hour: 11, occupancy_rate: 0.8, visits: 32 },
      { hour: 12, occupancy_rate: 0.6, visits: 24 },
      { hour: 13, occupancy_rate: 0.4, visits: 16 },
      { hour: 14, occupancy_rate: 0.9, visits: 36 },
      { hour: 15, occupancy_rate: 0.8, visits: 32 },
      { hour: 16, occupancy_rate: 0.95, visits: 38 },
      { hour: 17, occupancy_rate: 0.9, visits: 36 },
      { hour: 18, occupancy_rate: 0.7, visits: 28 },
      { hour: 19, occupancy_rate: 0.5, visits: 20 },
      { hour: 20, occupancy_rate: 0.3, visits: 12 }
    ],
    peak_hours: [14, 16, 17],
    average_session_duration: 45,
    updated_at: ISODate("2025-09-23T21:00:00Z")
  }
]);

print("✅ daily_zone_occupancy заполнена: " + db.daily_zone_occupancy.countDocuments() + " записей");

// Финальная проверка
print("\n🎯 ВСЕ КОЛЛЕКЦИИ ЗАПОЛНЕНЫ:");
print("class_attendance: " + db.class_attendance.countDocuments() + " записей");
print("trainer_statistics: " + db.trainer_statistics.countDocuments() + " записей");
print("daily_zone_occupancy: " + db.daily_zone_occupancy.countDocuments() + " записей");