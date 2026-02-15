package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDate;
import java.util.UUID;

public record ClientSummary(
        UUID clientId,
        String clientName,
        Long totalSpent,
        Long spendRank,
        LocalDate lastTransactionDate,
        Long lastTxAmount
) {}