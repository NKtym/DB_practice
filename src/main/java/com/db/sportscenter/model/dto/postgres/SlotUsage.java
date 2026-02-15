package com.db.sportscenter.model.dto.postgres;

import java.util.UUID;

public record SlotUsage(
        UUID slotId,
        UUID zoneId,
        Long bookingsCount,
        Long zoneTotalBookings,
        Double pctOfZone,
        Integer zoneRank
) {}