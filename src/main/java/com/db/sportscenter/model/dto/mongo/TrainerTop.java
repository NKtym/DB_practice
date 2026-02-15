package com.db.sportscenter.model.dto.mongo;

public record TrainerTop(
        String trainer_id,
        String trainer_name,
        Double rating,
        Integer total_attendance
) {}