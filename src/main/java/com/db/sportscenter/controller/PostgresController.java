package com.db.sportscenter.controller;

import com.db.sportscenter.model.dto.postgres.ClientSummary;
import com.db.sportscenter.model.dto.postgres.DailyProductRevenue;
import com.db.sportscenter.model.dto.postgres.MonthlyRevenue;
import com.db.sportscenter.model.dto.postgres.PaymentTypeStats;
import com.db.sportscenter.model.dto.postgres.SlotUsage;
import com.db.sportscenter.model.dto.postgres.TopClient;
import com.db.sportscenter.model.dto.postgres.TopEmployee;
import com.db.sportscenter.model.dto.postgres.TopProduct;
import com.db.sportscenter.model.dto.postgres.TransactionWithMovingAvg;
import com.db.sportscenter.repository.PostgresRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/postgres")
public class PostgresController {

    PostgresRepository postgresRepository;

    @Autowired
    PostgresController(PostgresRepository postgresRepository) {
        this.postgresRepository = postgresRepository;
    }

    @GetMapping("/top_clients")
    public ResponseEntity<List<ClientSummary>> getTopClients() {
        List<ClientSummary> clientSummary = postgresRepository.findTopClients();
        return ResponseEntity.ok(clientSummary);
    }

    @GetMapping("/transactions_with_moving_average")
    public ResponseEntity<List<TransactionWithMovingAvg>> getTransactionsWithMovingAverage() {
        List<TransactionWithMovingAvg> transactionsWithMovingAverage = postgresRepository.findTransactionsWithMovingAverage();
        return ResponseEntity.ok(transactionsWithMovingAverage);
    }

    @GetMapping("/slot_usage")
    public ResponseEntity<List<SlotUsage>> getSlotUsage() {
        List<SlotUsage> slotUsages = postgresRepository.findSlotUsageStatistics();
        return ResponseEntity.ok(slotUsages);
    }

    @GetMapping("/daily_revenue")
    public ResponseEntity<List<DailyProductRevenue>> getDailyProductRevenue() {
        List<DailyProductRevenue> dailyProductRevenues = postgresRepository.findDailyProductRevenue();
        return ResponseEntity.ok(dailyProductRevenues);
    }

    @GetMapping("/top_ten_clients")
    public ResponseEntity<List<TopClient>> getTopTenClientsByRevenue() {
        List<TopClient> topClients = postgresRepository.findTop10ClientsByRevenue();
        return ResponseEntity.ok(topClients);
    }

    @GetMapping("/year_revenue")
    public ResponseEntity<List<MonthlyRevenue>> getYearRevenue() {
        List<MonthlyRevenue> yearRevenue = postgresRepository.findYearRevenue();
        return ResponseEntity.ok(yearRevenue);
    }

    @GetMapping("/payment_statistics")
    public ResponseEntity<List<PaymentTypeStats>> getPaymentTypeStatistics() {
        List<PaymentTypeStats> paymentTypeStats = postgresRepository.findPaymentTypeStatistics();
        return ResponseEntity.ok(paymentTypeStats);
    }

    @GetMapping("/top_products")
    public ResponseEntity<List<TopProduct>> getTopProductsByRevenue() {
        List<TopProduct> topProducts = postgresRepository.findTop10ProductsByRevenue();
        return ResponseEntity.ok(topProducts);
    }

    @GetMapping("/top_employees")
    public ResponseEntity<List<TopEmployee>> getTopEmployeesByRevenue() {
        List<TopEmployee> topEmployees = postgresRepository.findTop10EmployeesLastYearByRevenue();
        return ResponseEntity.ok(topEmployees);
    }
}
