package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDate;
import java.util.Objects;
import java.util.UUID;

public record ProductDayKey(UUID productId, LocalDate day) {
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ProductDayKey that = (ProductDayKey) o;
        return Objects.equals(productId, that.productId) &&
                Objects.equals(day, that.day);
    }

    @Override
    public int hashCode() {
        return Objects.hash(productId, day);
    }
}
