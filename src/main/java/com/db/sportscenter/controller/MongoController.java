package com.db.sportscenter.controller;

import com.db.sportscenter.model.dto.mongo.ClassAttendance;
import com.db.sportscenter.model.dto.mongo.TrainerStatistics;
import com.db.sportscenter.model.dto.mongo.TrainerTop;
import com.db.sportscenter.model.dto.mongo.ZoneHourlyOccupancy;
import com.db.sportscenter.model.dto.mongo.ZonePeak;
import com.db.sportscenter.repository.MongoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/api/v1/mongo")
public class MongoController {

    private final MongoRepository repository;

    @Autowired
    MongoController(MongoRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/classes/{slot_id}")
    public ResponseEntity<ClassAttendance> getBySlotId(@PathVariable String slot_id) {
        return repository.findBySlotId(slot_id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/classes/upcoming")
    public List<ClassAttendance> upcomingClasses(
            @RequestParam("from")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Date from
    ) {
        return repository.findUpcomingClasses(from);
    }

    @GetMapping("/trainers/{trainer_id}/statistics")
    public ResponseEntity<TrainerStatistics> trainerStatistics(
            @PathVariable String trainer_id,
            @RequestParam String period
    ) {
        return repository.findTrainerStatistics(trainer_id, period)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/trainers/top/by-rating")
    public List<TrainerTop> topByRating(
            @RequestParam(defaultValue = "10") int limit,
            @RequestParam(defaultValue = "0") int offset
    ) {
        return repository.findTopTrainersByRating(
                Math.min(limit, 100),
                Math.max(offset, 0)
        );
    }

    @GetMapping("/trainers/top/by-attendance")
    public List<TrainerTop> topByAttendance(
            @RequestParam(defaultValue = "10") int limit,
            @RequestParam(defaultValue = "0") int offset
    ) {
        return repository.findTopTrainersByAttendance(
                Math.min(limit, 100),
                Math.max(offset, 0)
        );
    }

    @GetMapping("/zones/{zone_id}/hourly")
    public ResponseEntity<ZoneHourlyOccupancy> zoneHourly(
            @PathVariable String zone_id,
            @RequestParam
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Date date
    ) {
        return repository.findZoneHourly(zone_id, date)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/zones/peak")
    public List<ZonePeak> peakZones(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date from,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) Date to,
            @RequestParam(defaultValue = "10") int limit
    ) {
        return repository.findPeakZones(from, to, limit);
    }
}