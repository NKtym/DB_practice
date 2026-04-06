package com.db.sportscenter.model.dto;

import java.util.Map;

public class EventIngestRequest {
    private Long userId;
    private String eventType;
    private String eventTime; // ISO-8601: 2026-04-06T12:00:00
    private Map<String, Object> metadata;

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getEventTime() {
        return eventTime;
    }

    public void setEventTime(String eventTime) {
        this.eventTime = eventTime;
    }

    public Map<String, Object> getMetadata() {
        return metadata;
    }

    public void setMetadata(Map<String, Object> metadata) {
        this.metadata = metadata;
    }
}