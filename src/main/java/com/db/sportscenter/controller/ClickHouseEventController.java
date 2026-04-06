package com.db.sportscenter.controller;

import com.db.sportscenter.model.dto.EventIngestRequest;
import com.db.sportscenter.service.ClickHouseHttpIngestService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/events")
public class ClickHouseEventController {

    private final ClickHouseHttpIngestService service;

    public ClickHouseEventController(ClickHouseHttpIngestService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<?> ingest(@RequestBody EventIngestRequest request) {
        service.save(request);
        return ResponseEntity.ok(Map.of("status", "ok"));
    }
}