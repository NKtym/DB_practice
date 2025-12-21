db = db.getSiblingDB('sports_center');

print("📊 Заполняем trainer_statistics...");

db.trainer_statistics.insertMany([
  {
    trainer_id: "550e8400-e29b-41d4-a716-446655440010",
    period: "2025-09",
    trainer_name: "Анна Иванова",
    total_classes: 45,
    total_attendance: 765,
    average_attendance_rate: 0.85,
    total_capacity: 900,
    popular_classes: ["YOGA", "STRETCHING", "MEDITATION"],
    rating: 4.9,
    revenue_generated: 125000,
    client_satisfaction: 0.95,
    updated_at: ISODate("2025-09-23T17:00:00Z")
  },
  {
    trainer_id: "550e8400-e29b-41d4-a716-446655440011",
    period: "2025-09",
    trainer_name: "Петр Сидоров",
    total_classes: 38,
    total_attendance: 456,
    average_attendance_rate: 0.80,
    total_capacity: 570,
    popular_classes: ["PILATES", "STRETCHING"],
    rating: 4.7,
    revenue_generated: 98000,
    client_satisfaction: 0.88,
    updated_at: ISODate("2025-09-23T17:00:00Z")
  },
  {
    trainer_id: "550e8400-e29b-41d4-a716-446655440012",
    period: "2025-09",
    trainer_name: "Мария Петрова",
    total_classes: 52,
    total_attendance: 1144,
    average_attendance_rate: 0.88,
    total_capacity: 1300,
    popular_classes: ["CROSSFIT", "FUNCTIONAL", "STRENGTH"],
    rating: 4.8,
    revenue_generated: 156000,
    client_satisfaction: 0.92,
    updated_at: ISODate("2025-09-23T17:00:00Z")
  }
]);

print("✅ trainer_statistics заполнена: " + db.trainer_statistics.countDocuments() + " записей");