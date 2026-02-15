package com.db.sportscenter.model.dto.postgres;

import java.time.LocalDate;
import java.util.UUID;

public record ClientCard(
        UUID clientId,
        String firstName,
        String lastName,
        String phone,
        LocalDate registrationDate,
        CardStatus cardStatus,
        String preference
) {
}