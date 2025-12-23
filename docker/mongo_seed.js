db = db.getSiblingDB('sports_center');

function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomFloat(min, max, decimals=2) {
  return parseFloat((Math.random() * (max - min) + min).toFixed(decimals));
}

const class_types = ["YOGA","PILATES","CROSSFIT","STRETCHING","SWIMMING"];
const trainers = ["Анна Иванова","Петр Сидоров","Мария Петрова","Алексей Козлов","Елена Смирнова"];
const zones = ["Зал А","Зал Б","Тренажерный зал","Бассейн","Зал C"];

// -------------------------
// class_attendance: 1000 записей
// -------------------------
let class_attendance_bulk = [];
for (let i=1;i<=1000;i++){
  class_attendance_bulk.push({
    slot_id: "slot_"+i,
    trainer_id: "trainer_"+randomInt(1,50),
    zone_id: "zone_"+randomInt(1,20),
    date: new Date(2025, randomInt(0,11), randomInt(1,28)),
    start_time: `${randomInt(6,20)}:00`,
    end_time: `${randomInt(7,21)}:00`,
    max_capacity: randomInt(10,50),
    actual_attendance: randomInt(0,50),
    attendance_rate: randomFloat(0.0,1.0),
    status: "DONE",
    metadata: {
      class_type: class_types[randomInt(0,class_types.length-1)],
      trainer_name: trainers[randomInt(0,trainers.length-1)],
      zone_name: zones[randomInt(0,zones.length-1)],
      group_name: "Группа "+i
    },
    created_at: new Date()
  });
}
db.class_attendance.insertMany(class_attendance_bulk);
print("✅ class_attendance заполнена: " + db.class_attendance.countDocuments());

// -------------------------
// trainer_statistics: 1000 записей
// -------------------------
let trainer_statistics_bulk = [];
for (let i = 1; i <= 1000; i++) {
  trainer_statistics_bulk.push({
    trainer_id: "trainer_" + randomInt(1,50),
    period: `2025-${randomInt(1,12).toString().padStart(2,'0')}`,
    trainer_name: trainers[randomInt(0,trainers.length-1)],
    total_classes: randomInt(10,100),
    total_attendance: randomInt(100,1000),
    average_attendance_rate: randomFloat(0.5,1.0),
    total_capacity: randomInt(200,2000),
    popular_classes: [class_types[randomInt(0,class_types.length-1)], class_types[randomInt(0,class_types.length-1)]],
    rating: randomFloat(3.0,5.0),
    revenue_generated: randomInt(50000,200000),
    client_satisfaction: randomFloat(0.5,1.0),
    updated_at: new Date()
  });
}
db.trainer_statistics.insertMany(trainer_statistics_bulk);
print("✅ trainer_statistics заполнена: " + db.trainer_statistics.countDocuments());

// -------------------------
// daily_zone_occupancy: 1000 записей
// -------------------------
let daily_zone_occupancy_bulk = [];
for (let i = 1; i <= 1000; i++) {
  let hourly_occupancy = [];
  for (let h = 6; h <= 21; h++) {
    hourly_occupancy.push({ hour: h, occupancy_rate: randomFloat(0.0,1.0), visits: randomInt(0,50) });
  }
  db.daily_zone_occupancy.insertOne({
    zone_id: "zone_" + randomInt(1,20),
    zone_name: zones[randomInt(0,zones.length-1)],
    zone_type: ["GROUP_CLASS","GYM","POOL"][randomInt(0,2)],
    date: new Date(2025, randomInt(0,11), randomInt(1,28)),
    total_visits: randomInt(50,200),
    max_capacity: randomInt(80,250),
    occupancy_rate: randomFloat(0.5,1.0),
    hourly_occupancy: hourly_occupancy,
    peak_hours: [randomInt(6,21), randomInt(6,21), randomInt(6,21)],
    average_session_duration: randomInt(30,90),
    updated_at: new Date()
  });
}
db.daily_zone_occupancy.insertMany(daily_zone_occupancy_bulk);
print("✅ daily_zone_occupancy заполнена: " + db.daily_zone_occupancy.countDocuments());

// Финальная проверка
print("\n🎯 ВСЕ КОЛЛЕКЦИИ ЗАПОЛНЕНЫ:");
print("class_attendance: " + db.class_attendance.countDocuments() + " записей");
print("trainer_statistics: " + db.trainer_statistics.countDocuments() + " записей");
print("daily_zone_occupancy: " + db.daily_zone_occupancy.countDocuments() + " записей");
