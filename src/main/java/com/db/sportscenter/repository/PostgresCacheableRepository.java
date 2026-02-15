package com.db.sportscenter.repository;

import com.db.sportscenter.model.dto.postgres.CardStatus;
import com.db.sportscenter.model.dto.postgres.ClientCard;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public class PostgresCacheableRepository {

    private final JdbcTemplate jdbcTemplate;

    public PostgresCacheableRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Cacheable(
            value = "activeClients",
            unless = "#result == null || #result.isEmpty()"
    )
    public List<ClientCard> findActiveClients() {

        String sql = """
            SELECT
                c.client_id,
                c.first_name,
                c.last_name,
                c.phone,
                c.registration_date,
                c.card_status,
                c.preference
            FROM clients c
            WHERE c.card_status = 'ACTIVE'
            ORDER BY c.registration_date DESC
            LIMIT 500
        """;

        return jdbcTemplate.query(sql, (rs, rowNum) ->
                new ClientCard(
                        rs.getObject("client_id", UUID.class),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("phone"),
                        rs.getDate("registration_date").toLocalDate(),
                        CardStatus.valueOf(rs.getString("card_status")),
                        rs.getString("preference")
                )
        );
    }

    @CacheEvict(value = "activeClients", allEntries = true)
    public void updateCardStatus(UUID clientId, CardStatus status) {

        String sql = """
        UPDATE clients
        SET card_status = ?::card_status
        WHERE client_id = ?
    """;

        jdbcTemplate.update(
                sql,
                status.name(),
                clientId
        );
    }

    @CacheEvict(value = "activeClients", allEntries = true)
    public void insertClient(ClientCard dto) {

        String sql = """
        INSERT INTO clients (
            client_id,
            first_name,
            last_name,
            phone,
            registration_date,
            card_status,
            preference
        )
        VALUES (?, ?, ?, ?, ?, ?::card_status, ?)
    """;

        jdbcTemplate.update(
                sql,
                dto.clientId(),
                dto.firstName(),
                dto.lastName(),
                dto.phone(),
                dto.registrationDate(),
                dto.cardStatus().name(),
                dto.preference()
        );
    }

}
