package com.db.sportscenter.repository;

import com.db.sportscenter.model.dto.postgres.ClientSummary;
import com.db.sportscenter.model.dto.postgres.DailyProductRevenue;
import com.db.sportscenter.model.dto.postgres.MonthlyRevenue;
import com.db.sportscenter.model.dto.postgres.PaymentTypeStats;
import com.db.sportscenter.model.dto.postgres.ProductDayKey;
import com.db.sportscenter.model.dto.postgres.SlotUsage;
import com.db.sportscenter.model.dto.postgres.TopClient;
import com.db.sportscenter.model.dto.postgres.TopEmployee;
import com.db.sportscenter.model.dto.postgres.TopProduct;
import com.db.sportscenter.model.dto.postgres.TransactionWithMovingAvg;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
public class PostgresRepository {
    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public PostgresRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<DailyProductRevenue> findDailyProductRevenue() {
        String sql = """
            WITH calendar AS (
               SELECT generate_series(
                              MIN(date_trunc('day', datatime))::date,
                              MAX(date_trunc('day', datatime))::date,
                              '1 day'::interval
                      )::date AS day
               FROM transactions
               WHERE product_id IS NOT NULL
           ),
                all_products AS (
                    SELECT DISTINCT product_id
                    FROM transactions
                    WHERE product_id IS NOT NULL
                ),
                product_calendar AS (
                    SELECT p.product_id, c.day
                    FROM all_products p
                             CROSS JOIN calendar c
                ),
                daily AS (
                    SELECT
                        product_id,
                        date_trunc('day', datatime)::date AS day,
                        COALESCE(SUM(total_amount), 0) AS day_revenue
                    FROM transactions
                    WHERE product_id IS NOT NULL
                    GROUP BY product_id, day
                )
           SELECT
               pc.product_id,
               pc.day,
               COALESCE(d.day_revenue, 0) AS day_revenue,
               SUM(COALESCE(d.day_revenue, 0)) OVER (
                   PARTITION BY pc.product_id
                   ORDER BY pc.day
                   ) AS running_revenue,
               COALESCE(d.day_revenue, 0) -
               COALESCE(LAG(COALESCE(d.day_revenue, 0)) OVER (
                   PARTITION BY pc.product_id
                   ORDER BY pc.day
                   ), 0) AS diff_from_prev_day
           FROM product_calendar pc
                    LEFT JOIN daily d ON pc.product_id = d.product_id AND pc.day = d.day
           ORDER BY pc.product_id, pc.day;
           """;

        RowMapper<DailyProductRevenue> rowMapper = (rs, _) -> {
            UUID productId = rs.getObject("product_id", UUID.class);
            LocalDate day = rs.getDate("day").toLocalDate();
            Long dayRevenue = rs.getLong("day_revenue");
            Long runningRevenue = rs.getLong("running_revenue");
            Long diffFromPrevDay = rs.getLong("diff_from_prev_day");
            ProductDayKey id = new ProductDayKey(productId, day);
            return new DailyProductRevenue(id, productId, day, dayRevenue, runningRevenue, diffFromPrevDay);
        };

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<PaymentTypeStats> findPaymentTypeStatistics() {
        String sql = """
           SELECT
             t.payment_type,
             COUNT(*)            AS tx_count,
             SUM(t.total_amount) AS total_amount_raw,
             AVG(t.total_amount) AS avg_tx_amount_raw
           FROM transactions t
           GROUP BY t.payment_type
           ORDER BY total_amount_raw DESC;
           """;
        //ORDER BY SUM(t.total_amount) — повторная агрегация в ORDER BY

        RowMapper<PaymentTypeStats> rowMapper = (rs, rowNum) -> new PaymentTypeStats(
                rs.getString("payment_type"),
                rs.getLong("tx_count"),
                rs.getLong("total_amount_raw"),
                rs.getDouble("avg_tx_amount_raw")
        );

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<SlotUsage> findSlotUsageStatistics() {
        String sql = """
           SELECT
             s.slot_id,
             s.zone_id,
             COUNT(v.visit_id) AS bookings_count,
             SUM(COUNT(v.visit_id)) OVER (PARTITION BY s.zone_id) AS zone_total_bookings,
             ROUND(
               100.0 * COUNT(v.visit_id)
               / NULLIF(SUM(COUNT(v.visit_id)) OVER (PARTITION BY s.zone_id), 0),
               2
             ) AS pct_of_zone,
             RANK() OVER (
               PARTITION BY s.zone_id
               ORDER BY COUNT(v.visit_id) DESC
             ) AS zone_rank
           FROM slots s
           LEFT JOIN visits v ON v.slot_id = s.slot_id
           GROUP BY s.slot_id, s.zone_id
           ORDER BY s.zone_id, zone_rank
           LIMIT 100;
           """;
            // убран лишний CTE
            // меньше временных результатов

        RowMapper<SlotUsage> rowMapper = (rs, rowNum) -> new SlotUsage(
                rs.getObject("slot_id", UUID.class),
                rs.getObject("zone_id", UUID.class),
                rs.getLong("bookings_count"),
                rs.getLong("zone_total_bookings"),
                rs.getDouble("pct_of_zone"),
                rs.getInt("zone_rank")
        );

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<ClientSummary> findTopClients() {
        String sql = """
           
           WITH last_tx AS (
             SELECT DISTINCT ON (client_id)
               client_id,
               datatime AS last_transaction_date,
               total_amount AS last_tx_amount
             FROM transactions
             ORDER BY client_id, datatime DESC
           ),
           client_totals AS (
             SELECT
               client_id,
               SUM(total_amount) AS total_spent
             FROM transactions
             GROUP BY client_id
           )
           SELECT
             c.client_id,
             COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, '') AS client_name,
             COALESCE(ct.total_spent, 0) AS total_spent,
             RANK() OVER (ORDER BY COALESCE(ct.total_spent, 0) DESC) AS spend_rank,
             lt.last_transaction_date,
             lt.last_tx_amount
           FROM clients c
           LEFT JOIN client_totals ct ON c.client_id = ct.client_id
           LEFT JOIN last_tx lt ON c.client_id = lt.client_id
           ORDER BY COALESCE(ct.total_spent, 0) DESC
           LIMIT 100;
           """;
        // Уменьшенно колличесвто CTE с 3 до 2,

        RowMapper<ClientSummary> rowMapper = (rs, rowNum) -> new ClientSummary(
                rs.getObject("client_id", UUID.class),
                rs.getString("client_name"),
                rs.getLong("total_spent"),
                rs.getLong("spend_rank"),
                rs.getDate("last_transaction_date") != null ? rs.getDate("last_transaction_date").toLocalDate() : null,
                rs.getLong("last_tx_amount")
        );

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<TopClient> findTop10ClientsByRevenue() {
        String sql = """
           
           SELECT
             c.client_id,
             COALESCE(c.first_name, '') || ' ' || COALESCE(c.last_name, '') AS client_name,
             SUM(t.total_amount)                      AS total_spent_raw,
             MAX(t.datatime)                           AS last_transaction_date,
             COUNT(*)                                  AS tx_count
           FROM transactions t
           JOIN clients c ON c.client_id = t.client_id
           GROUP BY c.client_id, c.first_name, c.last_name
           ORDER BY SUM(t.total_amount) DESC
           LIMIT 10;
           """;

        RowMapper<TopClient> rowMapper = (rs, rowNum) -> new TopClient(
                rs.getObject("client_id", UUID.class),
                rs.getString("client_name"),
                rs.getLong("total_spent_raw"),
                rs.getDate("last_transaction_date") != null ? rs.getDate("last_transaction_date").toLocalDate() : null,
                rs.getLong("tx_count")
        );

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<TopEmployee> findTop10EmployeesLastYearByRevenue() {
        String sql = """
           WITH emp_sales AS (
             SELECT
               e.employee_id,
               e.first_name,
               e.last_name,
               COUNT(t.transaction_id) AS tx_count,
               SUM(t.total_amount)     AS total_sales,
               AVG(t.total_amount)     AS avg_check,
               MAX(t.datatime)         AS last_transaction_date
             FROM transactions t
             JOIN employees e ON e.employee_id = t.employee_id
             WHERE t.datatime >= CURRENT_DATE - INTERVAL '365 days'
             GROUP BY e.employee_id, e.first_name, e.last_name
           )
           SELECT
             employee_id,
             first_name || ' ' || last_name AS employee_name,
             tx_count,
             total_sales,
             ROUND(avg_check, 2) AS avg_check,
             ROUND(total_sales / 100.0, 2) AS total_sales_rub,
             RANK() OVER (ORDER BY total_sales DESC)        AS rank_by_revenue,
             DENSE_RANK() OVER (ORDER BY total_sales DESC) AS dense_rank,
             ROUND(
               100.0 * total_sales / SUM(total_sales) OVER (),
               2
             ) AS percent_of_total,
             last_transaction_date
           FROM emp_sales
           ORDER BY total_sales DESC
           LIMIT 10;
           """;
        // SUM(total_amount) считается один раз
        // оконные функции работают уже по маленькому набору данных (сотрудники, а не транзакции)

        RowMapper<TopEmployee> rowMapper = (rs, rowNum) -> new TopEmployee(
                rs.getObject("employee_id", UUID.class),
                rs.getString("employee_name"),
                rs.getLong("tx_count"),
                rs.getLong("total_sales"),
                rs.getDouble("avg_check"),
                rs.getDouble("total_sales_rub"),
                rs.getInt("rank_by_revenue"),
                rs.getInt("dense_rank"),
                rs.getDouble("percent_of_total"),
                rs.getDate("last_transaction_date") != null ? rs.getDate("last_transaction_date").toLocalDate() : null
        );

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<TopProduct> findTop10ProductsByRevenue() {
        String sql = """
           SELECT
             p.product_id,
             COALESCE(p.product_type, '<no name>') AS product_name,
             COUNT(*)            AS sales_count,
             SUM(t.total_amount) AS revenue_raw
           FROM transactions t
           JOIN products p ON p.product_id = t.product_id
           GROUP BY p.product_id, p.product_type
           ORDER BY revenue_raw DESC
           LIMIT 10;
           
           """;
        // GROUP BY по реальным полям таблицы

        RowMapper<TopProduct> rowMapper = (rs, rowNum) -> new TopProduct(
                rs.getObject("product_id", UUID.class),
                rs.getString("product_name"),
                rs.getLong("sales_count"),
                rs.getLong("revenue_raw")
        );

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<TransactionWithMovingAvg> findTransactionsWithMovingAverage() {
        String sql = """
           SELECT
           client_id,
           transaction_id,
           datatime,
           total_amount,
           AVG(total_amount) OVER (
             PARTITION BY client_id
             ORDER BY datatime
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           ) AS avg_last_3_amount
             FROM transactions
           ORDER BY client_id, datatime;
           """;

        RowMapper<TransactionWithMovingAvg> rowMapper = (rs, rowNum) -> new TransactionWithMovingAvg(
                rs.getObject("client_id", UUID.class),
                rs.getObject("transaction_id", UUID.class),
                rs.getTimestamp("datatime") != null ? rs.getTimestamp("datatime").toLocalDateTime() : null,
                rs.getInt("total_amount"),
                rs.getDouble("avg_last_3_amount")
        );

        return jdbcTemplate.query(sql, rowMapper);
    }

    public List<MonthlyRevenue> findYearRevenue() {
        String sql = """
           SELECT
             month,
             SUM(total_amount) AS month_revenue_raw,
             COUNT(*)          AS tx_count
           FROM (
             SELECT
               date_trunc('month', datatime) AS month,
               total_amount
             FROM transactions
             WHERE datatime >= date_trunc('month', current_date) - INTERVAL '11 months'
           ) t
           GROUP BY month
           ORDER BY month;
           """;
        //date_trunc считается один раз вместо трех
        //группировка и сортировка по готовому полю

        RowMapper<MonthlyRevenue> rowMapper = (rs, rowNum) -> new MonthlyRevenue(
                rs.getDate("month") != null ? rs.getDate("month").toLocalDate() : null,
                rs.getLong("month_revenue_raw"),
                rs.getLong("tx_count")
        );

        return jdbcTemplate.query(sql, rowMapper);
    }
}
