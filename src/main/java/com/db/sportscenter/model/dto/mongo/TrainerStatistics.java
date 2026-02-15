package com.db.sportscenter.model.dto.mongo;

public record TrainerStatistics(
        String trainer_id,
        String trainer_name,
        String period,
        Double rating,
        Integer total_attendance
) {}