db = db.getSiblingDB('sports_center');

print("📝 Заполняем class_attendance...");

db.class_attendance.insertMany([
  {
    slot_id: "550e8400-e29b-41d4-a716-446655440001",
    trainer_id: "550e8400-e29b-41d4-a716-446655440010",
    zone_id: "550e8400-e29b-41d4-a716-446655440020",
    date: ISODate("2025-09-23T00:00:00Z"),
    start_time: "09:00",
    end_time: "10:00",
    max_capacity: 20,
    actual_attendance: 18,
    attendance_rate: 0.9,
    status: "DONE",
    metadata: {
      class_type: "YOGA",
      trainer_name: "Анна Иванова",
      zone_name: "Зал А",
      group_name: "Утренняя йога"
    },
    created_at: ISODate("2025-09-23T10:05:00Z")
  },
  {
    slot_id: "550e8400-e29b-41d4-a716-446655440002",
    trainer_id: "550e8400-e29b-41d4-a716-446655440011",
    zone_id: "550e8400-e29b-41d4-a716-446655440021",
    date: ISODate("2025-09-23T00:00:00Z"),
    start_time: "10:30",
    end_time: "11:30",
    max_capacity: 15,
    actual_attendance: 12,
    attendance_rate: 0.8,
    status: "DONE",
    metadata: {
      class_type: "PILATES",
      trainer_name: "Петр Сидоров",
      zone_name: "Зал Б",
      group_name: "Пилатес для начинающих"
    },
    created_at: ISODate("2025-09-23T11:35:00Z")
  },
  {
    slot_id: "550e8400-e29b-41d4-a716-446655440003",
    trainer_id: "550e8400-e29b-41d4-a716-446655440012",
    zone_id: "550e8400-e29b-41d4-a716-446655440022",
    date: ISODate("2025-09-23T00:00:00Z"),
    start_time: "12:00",
    end_time: "13:00",
    max_capacity: 25,
    actual_attendance: 20,
    attendance_rate: 0.8,
    status: "DONE",
    metadata: {
      class_type: "CROSSFIT",
      trainer_name: "Мария Петрова",
      zone_name: "Тренажерный зал",
      group_name: "Функциональный тренинг"
    },
    created_at: ISODate("2025-09-23T13:05:00Z")
  },
  {
    slot_id: "550e8400-e29b-41d4-a716-446655440004",
    trainer_id: "550e8400-e29b-41d4-a716-446655440010",
    zone_id: "550e8400-e29b-41d4-a716-446655440020",
    date: ISODate("2025-09-23T00:00:00Z"),
    start_time: "14:00",
    end_time: "15:00",
    max_capacity: 20,
    actual_attendance: 15,
    attendance_rate: 0.75,
    status: "DONE",
    metadata: {
      class_type: "STRETCHING",
      trainer_name: "Анна Иванова",
      zone_name: "Зал А",
      group_name: "Стретчинг"
    },
    created_at: ISODate("2025-09-23T15:05:00Z")
  },
  {
    slot_id: "550e8400-e29b-41d4-a716-446655440005",
    trainer_id: "550e8400-e29b-41d4-a716-446655440013",
    zone_id: "550e8400-e29b-41d4-a716-446655440023",
    date: ISODate("2025-09-23T00:00:00Z"),
    start_time: "16:00",
    end_time: "17:00",
    max_capacity: 30,
    actual_attendance: 25,
    attendance_rate: 0.83,
    status: "DONE",
    metadata: {
      class_type: "SWIMMING",
      trainer_name: "Алексей Козлов",
      zone_name: "Бассейн",
      group_name: "Аквааэробика"
    },
    created_at: ISODate("2025-09-23T17:05:00Z")
  }
]);

print("✅ class_attendance заполнена: " + db.class_attendance.countDocuments() + " записей");