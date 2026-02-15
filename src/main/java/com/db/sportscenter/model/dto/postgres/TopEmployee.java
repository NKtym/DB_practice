package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDate;
import java.util.UUID;

public record TopEmployee(
        UUID employeeId,
        String employeeName,
        Long txCount,
        Long totalSales,
        Double avgCheck,
        Double totalSalesRub,
        Integer rankByRevenue,
        Integer denseRank,
        Double percentOfTotal,
        LocalDate lastTransactionDate
) {}