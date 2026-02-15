package com.db.sportscenter.model.dto.postgres;

public record PaymentTypeStats(
        String paymentType,
        Long txCount,
        Long totalAmountRaw,
        Double avgTxAmountRaw
) {}