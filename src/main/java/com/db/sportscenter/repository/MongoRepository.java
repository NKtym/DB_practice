package com.db.sportscenter.repository;

import com.db.sportscenter.model.dto.mongo.ClassAttendance;
import com.db.sportscenter.model.dto.mongo.TrainerStatistics;
import com.db.sportscenter.model.dto.mongo.TrainerTop;
import com.db.sportscenter.model.dto.mongo.ZoneHourlyOccupancy;
import com.db.sportscenter.model.dto.mongo.ZonePeak;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Repository
public class MongoRepository {

    private final MongoTemplate mongoTemplate;

    MongoRepository(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    public Optional<ClassAttendance> findBySlotId(String slotId) {
        Query query = new Query(Criteria.where("slot_id").is(slotId));
        query.fields().exclude("_id");

        return Optional.ofNullable(
                mongoTemplate.findOne(query, ClassAttendance.class, "class_attendance")
        );
    }

    public List<ClassAttendance> findUpcomingClasses(Date from) {
        Query query = new Query(
                Criteria.where("date").gte(from)
                        .and("status").is("PLANNED")
        );

        query.fields().exclude("_id");
        query.with(Sort.by(
                Sort.Order.asc("date"),
                Sort.Order.asc("start_time")
        ));

        return mongoTemplate.find(query, ClassAttendance.class, "class_attendance");
    }

    public Optional<TrainerStatistics> findTrainerStatistics(String trainerId, String period) {
        Query query = new Query(
                Criteria.where("trainer_id").is(trainerId)
                        .and("period").is(period)
        );

        query.fields().exclude("_id");

        return Optional.ofNullable(
                mongoTemplate.findOne(query, TrainerStatistics.class, "trainer_statistics")
        );
    }

    public List<TrainerTop> findTopTrainersByRating(int limit, int offset) {
        Query query = new Query()
                .with(Sort.by(Sort.Direction.DESC, "rating"))
                .skip(offset)
                .limit(limit);

        query.fields()
                .exclude("_id")
                .include("trainer_id")
                .include("trainer_name")
                .include("rating")
                .include("total_attendance");

        return mongoTemplate.find(query, TrainerTop.class, "trainer_statistics");
    }

    public List<TrainerTop> findTopTrainersByAttendance(int limit, int offset) {
        Query query = new Query()
                .with(Sort.by(Sort.Direction.DESC, "total_attendance"))
                .skip(offset)
                .limit(limit);

        query.fields()
                .exclude("_id")
                .include("trainer_id")
                .include("trainer_name")
                .include("rating")
                .include("total_attendance");

        return mongoTemplate.find(query, TrainerTop.class, "trainer_statistics");
    }

    /* -------------------- zones -------------------- */

    public Optional<ZoneHourlyOccupancy> findZoneHourly(String zoneId, Date date) {

        Aggregation aggregation = Aggregation.newAggregation(
                Aggregation.match(
                        Criteria.where("zone_id").is(zoneId)
                                .and("date").is(date)
                ),
                Aggregation.project("zone_id", "zone_name", "hourly_occupancy")
                        .andExclude("_id")
        );

        return Optional.ofNullable(
                mongoTemplate.aggregate(
                        aggregation,
                        "daily_zone_occupancy",
                        ZoneHourlyOccupancy.class
                ).getUniqueMappedResult()
        );
    }

    public List<ZonePeak> findPeakZones(Date from, Date to, int limit) {

        Aggregation aggregation = Aggregation.newAggregation(
                Aggregation.match(
                        Criteria.where("date").gte(from).lte(to)
                ),
                Aggregation.group("zone_id", "zone_name")
                        .avg("occupancy_rate").as("avgOccupancy")
                        .sum("total_visits").as("totalVisits"),
                Aggregation.sort(Sort.Direction.DESC, "avgOccupancy"),
                Aggregation.limit(limit),
                Aggregation.project("avgOccupancy", "totalVisits")
                        .and("_id.zone_id").as("zone_id")
                        .and("_id.zone_name").as("zone_name")
                        .andExclude("_id")
        );

        return mongoTemplate.aggregate(
                aggregation,
                "daily_zone_occupancy",
                ZonePeak.class
        ).getMappedResults();
    }
}