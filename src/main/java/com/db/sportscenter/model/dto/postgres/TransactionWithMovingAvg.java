package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDateTime;
import java.util.UUID;

public record TransactionWithMovingAvg(
        UUID clientId,
        UUID transactionId,
        LocalDateTime dataTime,
        Integer totalAmount,
        Double avgLast3Amount
) {}