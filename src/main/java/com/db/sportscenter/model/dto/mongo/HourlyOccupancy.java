package com.db.sportscenter.model.dto.mongo;

public record HourlyOccupancy(
        Integer hour,
        Double occupancy_rate,
        Integer visits
) {}