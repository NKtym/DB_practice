package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDate;
import java.util.UUID;

public record DailyProductRevenue(
        ProductDayKey id,
        UUID productId,
        LocalDate day,
        Long dayRevenue,
        Long runningRevenue,
        Long diffFromPrevDay
) {}