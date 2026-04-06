package com.db.sportscenter.service;

import com.db.sportscenter.model.dto.EventIngestRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class ClickHouseHttpIngestService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper;

    @Value("${clickhouse.http-url}")
    private String clickHouseHttpUrl;

    @Value("${clickhouse.database}")
    private String database;

    @Value("${clickhouse.username}")
    private String username;

    @Value("${clickhouse.password}")
    private String password;

    public ClickHouseHttpIngestService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public void save(EventIngestRequest request) {
        try {
            String eventTime = request.getEventTime() == null || request.getEventTime().isBlank()
                    ? LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
                    : LocalDateTime.parse(request.getEventTime())
                        .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

            String metadataJson = request.getMetadata() == null
                    ? "{}"
                    : objectMapper.writeValueAsString(request.getMetadata());

            Map<String, Object> row = new LinkedHashMap<>();
            row.put("user_id", request.getUserId());
            row.put("event_type", request.getEventType());
            row.put("event_time", eventTime);
            row.put("metadata", metadataJson);

            String body = objectMapper.writeValueAsString(row);

            String url = clickHouseHttpUrl
                    + "?database=" + enc(database)
                    + "&user=" + enc(username)
                    + "&password=" + enc(password)
                    + "&query=" + enc("INSERT INTO events FORMAT JSONEachRow");

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.TEXT_PLAIN);

            restTemplate.postForEntity(url, new HttpEntity<>(body, headers), String.class);
        } catch (Exception e) {
            throw new RuntimeException("ClickHouse HTTP insert failed: " + e.getMessage(), e);
        }
    }

    private String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}