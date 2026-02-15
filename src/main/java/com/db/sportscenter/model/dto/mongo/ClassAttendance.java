package com.db.sportscenter.model.dto.mongo;

import java.util.Date;

public record ClassAttendance (
        String slot_id,
        String trainer_id,
        String zone_id,
        Date date,
        String status,
        Double attendance_rate
) {}
