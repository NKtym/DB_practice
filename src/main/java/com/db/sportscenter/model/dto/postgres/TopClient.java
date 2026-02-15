package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDate;
import java.util.UUID;

public record TopClient(
        UUID clientId,
        String clientName,
        Long totalSpentRaw,
        LocalDate lastTransactionDate,
        Long txCount
) {}