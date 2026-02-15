package com.db.sportscenter.model.dto.mongo;

import java.util.List;

public record ZoneHourlyOccupancy(
        String zone_id,
        String zone_name,
        List<HourlyOccupancy> hourly_occupancy
) {}