package com.db.sportscenter.model.dto.mongo;

public record ZonePeak(
        String zone_id,
        String zone_name,
        Double avgOccupancy,
        Integer totalVisits
) {}