#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C
export LANG=C

ROWS="${1:-100000}"
OUT_FILE="${2:-./clickhouse_test_data.tsv}"

> "$OUT_FILE"
echo -e "event_id\tevent_time\tevent_type\tentity_type\tentity_id\tclient_id\temployee_id\tproduct_id\tslot_id\tzone_id\ttransaction_id\tamount\tquantity\tpayment_type\tsource\tmetadata" >> "$OUT_FILE"

START_TS=$(date -u -d '2026-03-01 00:00:00' +%s)
DAYS=28

awk -v rows="$ROWS" -v out_file="$OUT_FILE" -v start_ts="$START_TS" -v days="$DAYS" '
function rand_int(max) { return int(rand() * max) }
function hex(len,    i, s, digits) {
    digits = "0123456789abcdef"
    s = ""
    for (i = 0; i < len; i++) s = s substr(digits, int(rand() * 16) + 1, 1)
    return s
}
function uuid() {
    return hex(8) "-" hex(4) "-" hex(4) "-" hex(4) "-" hex(12)
}
function ts_string(epoch) {
    return strftime("%Y-%m-%d %H:%M:%S", epoch, 1)
}

BEGIN {
    srand()

    event_types[1] = "VISIT_STARTED"
    event_types[2] = "TRANSACTION_CREATED"
    event_types[3] = "PRODUCT_SOLD"
    event_types[4] = "SLOT_BOOKED"

    entity_types[1] = "visit"
    entity_types[2] = "transaction"
    entity_types[3] = "product"
    entity_types[4] = "slot"

    payment_types[1] = "card"
    payment_types[2] = "cash"
    payment_types[3] = "online"
    payment_types[4] = "bonus"

    channels[1] = "mobile"
    channels[2] = "web"
    channels[3] = "admin"
    channels[4] = "kiosk"

    burst_days[1] = 3
    burst_days[2] = 6
    burst_days[3] = 10
    burst_days[4] = 17
    burst_days[5] = 24

    # пулы для повторяющихся сущностей
    client_pool = 600
    employee_pool = 48
    product_pool = 120
    slot_pool = 80
    zone_pool = 12

    for (i = 1; i <= rows; i++) {

        day_offset = rand_int(days)

        # всплески активности
        is_burst_day = 0
        for (b = 1; b <= 5; b++) {
            if (day_offset == burst_days[b]) {
                is_burst_day = 1
                break
            }
        }

        if (is_burst_day && rand() < 0.75) {
            hour = (rand() < 0.55) ? (9 + rand_int(4)) : (17 + rand_int(4))
        } else if (rand() < 0.50) {
            hour = 8 + rand_int(12)
        } else {
            hour = rand_int(24)
        }

        minute = rand_int(60)
        second = rand_int(60)

        epoch = start_ts + day_offset * 86400 + hour * 3600 + minute * 60 + second
        event_time = ts_string(epoch)

        # распределение типов событий
        r = rand()
        if (r < 0.38) {
            et = event_types[1]
            ent = entity_types[1]
            amount = 0
            qty = 1
            pay = "\\N"
        } else if (r < 0.66) {
            et = event_types[2]
            ent = entity_types[2]
            amount = 800 + rand_int(4200) + (rand_int(100) / 100)
            qty = 1
            pay = payment_types[1 + rand_int(4)]
        } else if (r < 0.88) {
            et = event_types[3]
            ent = entity_types[3]
            amount = 100 + rand_int(2900) + (rand_int(100) / 100)
            qty = 1 + rand_int(3)
            pay = payment_types[1 + rand_int(3)]
        } else {
            et = event_types[4]
            ent = entity_types[4]
            amount = 0
            qty = 1
            pay = "\\N"
        }

        # ПОВТОРЯЕМЫЕ entity_id (важно для задания)
        if (et == "VISIT_STARTED") {
            entity_id = 1000 + rand_int(300)
        } else if (et == "TRANSACTION_CREATED") {
            entity_id = 2000 + rand_int(200)
        } else if (et == "PRODUCT_SOLD") {
            entity_id = 3000 + rand_int(120)
        } else {
            entity_id = 4000 + rand_int(80)
        }

        client_id = 10000 + rand_int(client_pool)
        employee_id = 2000 + rand_int(employee_pool)
        product_id = 3000 + rand_int(product_pool)
        slot_id = 4000 + rand_int(slot_pool)
        zone_id = 10 + rand_int(zone_pool)
        transaction_id = 500000 + rand_int(500000)

        # NULL-логика
        if (et == "VISIT_STARTED") {
            employee_id = "\\N"
            product_id = "\\N"
            slot_id = "\\N"
            transaction_id = "\\N"
        } else if (et == "TRANSACTION_CREATED") {
            slot_id = "\\N"
            zone_id = "\\N"
        } else if (et == "PRODUCT_SOLD") {
            slot_id = "\\N"
            transaction_id = "\\N"
        } else if (et == "SLOT_BOOKED") {
            product_id = "\\N"
            transaction_id = "\\N"
            amount = 0
            pay = "\\N"
        }

        source = "sport_center"
        channel = channels[1 + rand_int(4)]

        metadata = sprintf("{\"channel\":\"%s\",\"burst_day\":%s,\"day_offset\":%d}",
                           channel,
                           (is_burst_day ? "true" : "false"),
                           day_offset)

        printf("%s\t%s\t%s\t%s\t%u\t%s\t%s\t%s\t%s\t%s\t%s\t%.2f\t%u\t%s\t%s\t%s\n",
               uuid(), event_time, et, ent, entity_id,
               client_id, employee_id, product_id, slot_id, zone_id, transaction_id,
               amount, qty, pay, source, metadata) >> out_file
    }
}
' >/dev/null

echo "Generated ${ROWS} rows into ${OUT_FILE}"