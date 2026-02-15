package com.db.sportscenter.model.dto.postgres;

import java.util.UUID;

public record TopProduct(
        UUID productId,
        String productName,
        Long salesCount,
        Long revenueRaw
) {}