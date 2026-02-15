package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDate;

public record MonthlyRevenue(
        LocalDate month,
        Long monthRevenueRaw,
        Long txCount
) {}