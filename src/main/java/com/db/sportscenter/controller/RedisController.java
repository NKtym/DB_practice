package com.db.sportscenter.controller;

import com.db.sportscenter.model.dto.postgres.CardStatus;
import com.db.sportscenter.model.dto.postgres.ClientCard;
import com.db.sportscenter.repository.PostgresCacheableRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/redis")
public class RedisController {

    private final PostgresCacheableRepository postgresCacheableRepository;

    public RedisController(PostgresCacheableRepository postgresCacheableRepository) {
        this.postgresCacheableRepository = postgresCacheableRepository;
    }

    @GetMapping("/active")
    public List<ClientCard> getActiveClients() {
        return postgresCacheableRepository.findActiveClients();
    }

    @PostMapping
    public void createClient(@RequestBody ClientCard dto) {
        postgresCacheableRepository.insertClient(dto);
    }

    @PutMapping("/{clientId}/status")
    public void updateStatus(
            @PathVariable UUID clientId,
            @RequestParam String status
    ) {
        postgresCacheableRepository.updateCardStatus(clientId, CardStatus.valueOf(status));
    }
}
