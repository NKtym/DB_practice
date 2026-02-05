package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/neo4j/neo4j-go-driver/v5/neo4j"
)

// ----------------- DEFAULTS -----------------
const (
	defaultPGHost  = "localhost"
	defaultPGPort  = 5433 // учтите, что на хосте у вас проброшен 5433:5432
	defaultPGUser  = "appuser"
	defaultPGPass  = "secretpassword"
	defaultPGDB    = "appdb"
	defaultNeoURI  = "bolt://localhost:7687"
	defaultNeoUser = "neo4j"
	defaultNeoPass = "1234554321"
	defaultBatch   = 1000
)

// Структуры для данных (UUIDs храним как строки)
type Client struct {
	ID        string
	FirstName string
	LastName  string
}

type Product struct {
	ID       string
	Category string
}

type Transaction struct {
	ClientID  string
	ProductID string
	Datetime  time.Time
}

type Group struct {
	ID        string
	Name      string
	TrainerID string
}

type GroupClient struct {
	GroupID  string
	ClientID string
}

type NeoClient struct {
	ID   string
	Name string
}

type NeoProduct struct {
	ID       string
	Category string
}

type NeoInteraction struct {
	UID string
	PID string
	TS  int64
}

type NeoGroup struct {
	ID   string
	Name string
}

func main() {
	// Парсинг аргументов командной строки с учетом переменных окружения
	pgHost := getEnv("PG_HOST", defaultPGHost)
	pgPort := getEnvAsInt("PG_PORT", defaultPGPort)
	pgUser := getEnv("PG_USER", defaultPGUser)
	pgPass := getEnv("PG_PASS", defaultPGPass)
	pgDB := getEnv("PG_DB", defaultPGDB)

	neoURI := getEnv("NEO_URI", defaultNeoURI)
	neoUser := getEnv("NEO_USER", defaultNeoUser)
	neoPass := getEnv("NEO_PASS", defaultNeoPass)

	batchSize := getEnvAsInt("BATCH_SIZE", defaultBatch)

	// Флаги командной строки (имеют приоритет над переменными окружения)
	flag.StringVar(&pgHost, "pg-host", pgHost, "PostgreSQL host")
	flag.IntVar(&pgPort, "pg-port", pgPort, "PostgreSQL port")
	flag.StringVar(&pgUser, "pg-user", pgUser, "PostgreSQL username")
	flag.StringVar(&pgPass, "pg-pass", pgPass, "PostgreSQL password")
	flag.StringVar(&pgDB, "pg-db", pgDB, "PostgreSQL database name")

	flag.StringVar(&neoURI, "neo-uri", neoURI, "Neo4j URI")
	flag.StringVar(&neoUser, "neo-user", neoUser, "Neo4j username")
	flag.StringVar(&neoPass, "neo-pass", neoPass, "Neo4j password")

	flag.IntVar(&batchSize, "batch", batchSize, "Batch size for Neo4j operations")

	flag.Parse()

	fmt.Println("=== Загрузка данных из PostgreSQL в Neo4j ===")
	fmt.Printf("PostgreSQL: %s:%d/%s\n", pgHost, pgPort, pgDB)
	fmt.Printf("Neo4j: %s\n", neoURI)

	fmt.Println("\nПодключаемся к Postgres...")

	// Подключение к PostgreSQL
	connStr := fmt.Sprintf("postgres://%s:%s@%s:%d/%s",
		pgUser, pgPass, pgHost, pgPort, pgDB)

	conn, err := pgx.Connect(context.Background(), connStr)
	if err != nil {
		log.Fatalf("Ошибка подключения к PostgreSQL: %v", err)
	}
	defer conn.Close(context.Background())

	// Загрузка клиентов
	fmt.Println("Подгружаем клиентов...")
	clients, err := fetchClients(conn)
	if err != nil {
		log.Fatalf("Ошибка загрузки клиентов: %v", err)
	}
	fmt.Printf("✓ Клиентов загружено: %d\n", len(clients))

	// Загрузка продуктов
	fmt.Println("Подгружаем продукты...")
	products, err := fetchProducts(conn)
	if err != nil {
		log.Fatalf("Ошибка загрузки продуктов: %v", err)
	}
	fmt.Printf("✓ Продуктов загружено: %d\n", len(products))

	// Загрузка транзакций
	fmt.Println("Подгружаем транзакции (покупки)...")
	transactions, err := fetchTransactions(conn)
	if err != nil {
		log.Fatalf("Ошибка загрузки транзакций: %v", err)
	}
	fmt.Printf("✓ Транзакций загружено: %d\n", len(transactions))

	// Загрузка групп и связей
	fmt.Println("Подгружаем группы...")
	groups, err := fetchGroups(conn)
	if err != nil {
		log.Fatalf("Ошибка загрузки groups: %v", err)
	}
	fmt.Printf("✓ Групп загружено: %d\n", len(groups))

	fmt.Println("Подгружаем group_clients...")
	gcs, err := fetchGroupClients(conn)
	if err != nil {
		log.Fatalf("Ошибка загрузки group_clients: %v", err)
	}
	fmt.Printf("✓ Group-Client связей загружено: %d\n", len(gcs))

	// Подключение к Neo4j
	fmt.Println("\nПодключаемся к Neo4j...")
	driver, err := neo4j.NewDriver(neoURI, neo4j.BasicAuth(neoUser, neoPass, ""))
	if err != nil {
		log.Fatalf("Ошибка создания драйвера Neo4j: %v", err)
	}
	defer func() {
		_ = driver.Close()
	}()

	// Проверяем подключение
	if err := driver.VerifyConnectivity(); err != nil {
		log.Fatalf("Ошибка подключения к Neo4j: %v", err)
	}

	// Создание сессии Neo4j (write) с явным указанием базы
	session := driver.NewSession(neo4j.SessionConfig{AccessMode: neo4j.AccessModeWrite, DatabaseName: "neo4j"})
	defer session.Close()

	// Создание ограничений
	fmt.Println("Создаём ограничения в Neo4j...")
	if err := createConstraints(session); err != nil {
		log.Fatalf("Ошибка создания ограничений: %v", err)
	}
	fmt.Println("✓ Ограничения созданы")

	// Подготовка данных для Neo4j
	fmt.Println("\nПодготавливаем данные...")
	neoClients := prepareClients(clients)
	neoProducts := prepareProducts(products)
	neoInteractions := prepareInteractions(transactions)
	neoGroups := prepareGroups(groups)
	groupMembershipRows := prepareGroupMemberships(gcs)

	// Запись пользователей в Neo4j
	fmt.Println("Записываем пользователей в Neo4j...")
	if err := writeUsers(session, neoClients, batchSize); err != nil {
		log.Fatalf("Ошибка записи пользователей: %v", err)
	}
	fmt.Printf("✓ Пользователей записано/обновлено: %d\n", len(neoClients))

	// Запись продуктов в Neo4j
	fmt.Println("Записываем продукты в Neo4j...")
	if err := writeProducts(session, neoProducts, batchSize); err != nil {
		log.Fatalf("Ошибка записи продуктов: %v", err)
	}
	fmt.Printf("✓ Продуктов записано/обновлено: %d\n", len(neoProducts))
	//Запись групп
	fmt.Println("Записываем группы в Neo4j...")
	if err := writeGroups(session, neoGroups, batchSize); err != nil {
		log.Fatalf("Ошибка записи групп: %v", err)
	}
	fmt.Printf("✓ Групп записано/обновлено: %d\n", len(neoGroups))

	// Создание связей
	fmt.Println("Создаём связи MEMBER_OF (User -> Group)...")
	if err := createGroupMemberships(session, groupMembershipRows, batchSize); err != nil {
		log.Fatalf("Ошибка создания связей групп: %v", err)
	}
	fmt.Printf("✓ Создано/обновлено связей MEMBER_OF: %d\n", len(groupMembershipRows))

	// Создание отношений PURCHASED
	fmt.Println("Создаём отношения PURCHASED...")
	if err := createPurchasedRelations(session, neoInteractions, batchSize); err != nil {
		log.Fatalf("Ошибка создания отношений: %v", err)
	}
	fmt.Printf("✓ Обработано отношений: %d\n", len(neoInteractions))

	fmt.Println("\n✅ Готово! Все данные успешно загружены в Neo4j.")
}

// Вспомогательные функции для работы с переменными окружения
func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	strValue := getEnv(key, "")
	if strValue == "" {
		return defaultValue
	}
	value, err := strconv.Atoi(strValue)
	if err != nil {
		log.Printf("Неверное значение для %s: %v, используем значение по умолчанию: %d", key, err, defaultValue)
		return defaultValue
	}
	return value
}

// Функции для работы с PostgreSQL
func fetchClients(conn *pgx.Conn) ([]Client, error) {
	rows, err := conn.Query(context.Background(),
		"SELECT client_id::text, first_name, last_name FROM public.clients LIMIT 50")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var clients []Client
	for rows.Next() {
		var c Client
		if err := rows.Scan(&c.ID, &c.FirstName, &c.LastName); err != nil {
			return nil, err
		}
		clients = append(clients, c)
	}
	return clients, rows.Err()
}

func fetchProducts(conn *pgx.Conn) ([]Product, error) {
	rows, err := conn.Query(context.Background(),
		"SELECT product_id::text, category FROM public.products LIMIT 50")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var products []Product
	for rows.Next() {
		var p Product
		if err := rows.Scan(&p.ID, &p.Category); err != nil {
			return nil, err
		}
		products = append(products, p)
	}
	return products, rows.Err()
}

func fetchTransactions(conn *pgx.Conn) ([]Transaction, error) {
	rows, err := conn.Query(context.Background(),
		"SELECT client_id::text, product_id::text, datatime FROM public.transactions LIMIT 50")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var transactions []Transaction
	for rows.Next() {
		var t Transaction
		if err := rows.Scan(&t.ClientID, &t.ProductID, &t.Datetime); err != nil {
			return nil, err
		}
		transactions = append(transactions, t)
	}
	return transactions, rows.Err()
}

func fetchGroups(conn *pgx.Conn) ([]Group, error) {
	rows, err := conn.Query(context.Background(),
		"SELECT group_id::text, name, trainer_id::text FROM public.groups LIMIT 50")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var groups []Group
	for rows.Next() {
		var g Group
		if err := rows.Scan(&g.ID, &g.Name, &g.TrainerID); err != nil {
			return nil, err
		}
		groups = append(groups, g)
	}
	return groups, rows.Err()
}

func fetchGroupClients(conn *pgx.Conn) ([]GroupClient, error) {
	rows, err := conn.Query(context.Background(),
		"SELECT group_id::text, client_id::text FROM public.group_clients LIMIT 200")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var gcs []GroupClient
	for rows.Next() {
		var gc GroupClient
		if err := rows.Scan(&gc.GroupID, &gc.ClientID); err != nil {
			return nil, err
		}
		gcs = append(gcs, gc)
	}
	return gcs, rows.Err()
}

// Функции для работы с Neo4j
func createConstraints(session neo4j.Session) error {
	// Создание ограничения для пользователей
	_, err := session.Run(
		"CREATE CONSTRAINT IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE",
		nil,
	)
	if err != nil {
		return err
	}

	_, err = session.Run(
		"CREATE CONSTRAINT IF NOT EXISTS FOR (p:Product) REQUIRE p.id IS UNIQUE",
		nil,
	)
	if err != nil {
		return err
	}

	_, err = session.Run(
		"CREATE CONSTRAINT IF NOT EXISTS FOR (g:Group) REQUIRE g.id IS UNIQUE",
		nil,
	)
	if err != nil {
		return err
	}
	//индекс
	_, err = session.Run(
		"CREATE INDEX IF NOT EXISTS FOR (p:Product) ON (p.category)",
		nil,
	)
	if err != nil {
		return err
	}

	return nil
}

func prepareClients(clients []Client) []NeoClient {
	neoClients := make([]NeoClient, 0, len(clients))
	for _, client := range clients {
		neoClients = append(neoClients, NeoClient{
			ID:   client.ID,
			Name: strings.TrimSpace(client.FirstName + " " + client.LastName),
		})
	}
	return neoClients
}

func prepareProducts(products []Product) []NeoProduct {
	neoProducts := make([]NeoProduct, 0, len(products))
	for _, product := range products {
		category := product.Category
		if category == "" {
			category = ""
		}
		neoProducts = append(neoProducts, NeoProduct{
			ID:       product.ID,
			Category: category,
		})
	}
	return neoProducts
}

func prepareInteractions(transactions []Transaction) []NeoInteraction {
	neoInteractions := make([]NeoInteraction, 0, len(transactions))
	for _, tx := range transactions {
		neoInteractions = append(neoInteractions, NeoInteraction{
			UID: tx.ClientID,
			PID: tx.ProductID,
			TS:  toTimestampMillis(tx.Datetime),
		})
	}
	return neoInteractions
}

func prepareGroups(groups []Group) []NeoGroup {
	neo := make([]NeoGroup, 0, len(groups))
	for _, g := range groups {
		neo = append(neo, NeoGroup{
			ID:   g.ID,
			Name: strings.TrimSpace(g.Name),
		})
	}
	return neo
}

func prepareGroupMemberships(gcs []GroupClient) []map[string]any {
	rows := make([]map[string]any, 0, len(gcs))
	for _, gc := range gcs {
		rows = append(rows, map[string]any{
			"group_id":  gc.GroupID,
			"client_id": gc.ClientID,
		})
	}
	return rows
}

func writeUsers(session neo4j.Session, clients []NeoClient, batchSize int) error {
	for i := 0; i < len(clients); i += batchSize {
		end := i + batchSize
		if end > len(clients) {
			end = len(clients)
		}
		batch := clients[i:end]

		// конвертируем в []map[string]any
		rows := make([]map[string]any, 0, len(batch))
		for _, c := range batch {
			rows = append(rows, map[string]any{"id": c.ID, "name": c.Name})
		}

		res, err := session.Run(`
    UNWIND $rows AS r
    MERGE (u:User {id: r.id})
    SET u.name = coalesce(u.name, r.name)
`, map[string]any{"rows": rows})
		if err != nil {
			return err
		}
		sum, err := res.Consume()
		if err == nil {
			fmt.Printf("Users batch %d..%d - NodesCreated=%d, PropertiesSet=%d\n", i, end, sum.Counters().NodesCreated(), sum.Counters().PropertiesSet())
		}
	}
	return nil
}

func writeProducts(session neo4j.Session, products []NeoProduct, batchSize int) error {
	for i := 0; i < len(products); i += batchSize {
		end := i + batchSize
		if end > len(products) {
			end = len(products)
		}
		batch := products[i:end]

		rows := make([]map[string]any, 0, len(batch))
		for _, p := range batch {
			rows = append(rows, map[string]any{"id": p.ID, "category": p.Category})
		}

		res, err := session.Run(`
    UNWIND $rows AS r
    MERGE (p:Product {id: r.id})
    SET p.category = coalesce(p.category, r.category)
`, map[string]any{"rows": rows})
		if err != nil {
			return err
		}
		sum, err := res.Consume()
		if err == nil {
			fmt.Printf("Products batch %d..%d - NodesCreated=%d, PropertiesSet=%d\n", i, end, sum.Counters().NodesCreated(), sum.Counters().PropertiesSet())
		}
	}
	return nil
}

func createPurchasedRelations(session neo4j.Session, interactions []NeoInteraction, batchSize int) error {
	for i := 0; i < len(interactions); i += batchSize {
		end := i + batchSize
		if end > len(interactions) {
			end = len(interactions)
		}
		batch := interactions[i:end]

		rows := make([]map[string]any, 0, len(batch))
		for _, it := range batch {
			rows = append(rows, map[string]any{"uid": it.UID, "pid": it.PID, "ts": it.TS})
		}

		// MERGE узлов по id (если нет) — затем MERGE ребро по паре (u,p).
		// Свойства задаём только если их нет (coalesce), чтобы не перезаписывать существующие значения.
		res, err := session.Run(`
    UNWIND $rows AS r
    MERGE (u:User {id: r.uid})
    MERGE (p:Product {id: r.pid})
    MERGE (u)-[rel:PURCHASED]->(p)
    SET rel.ts = coalesce(rel.ts, r.ts)
    RETURN count(rel) AS rels
`, map[string]any{"rows": rows})
		if err != nil {
			return err
		}
		sum, err := res.Consume()
		if err == nil {
			fmt.Printf("Purchased batch %d..%d - RelationshipsCreated=%d, PropertiesSet=%d\n", i, end, sum.Counters().RelationshipsCreated(), sum.Counters().PropertiesSet())
		}
	}
	return nil
}

func writeGroups(session neo4j.Session, groups []NeoGroup, batchSize int) error {
	for i := 0; i < len(groups); i += batchSize {
		end := i + batchSize
		if end > len(groups) {
			end = len(groups)
		}
		batch := groups[i:end]

		rows := make([]map[string]any, 0, len(batch))
		for _, g := range batch {
			rows = append(rows, map[string]any{"id": g.ID, "name": g.Name})
		}

		res, err := session.Run(`
    UNWIND $rows AS r
    MERGE (g:Group {id: r.id})
    SET g.name = coalesce(g.name, r.name)
`, map[string]any{"rows": rows})
		if err != nil {
			return err
		}
		sum, err := res.Consume()
		if err == nil {
			fmt.Printf("Groups batch %d..%d - NodesCreated=%d, PropertiesSet=%d\n", i, end, sum.Counters().NodesCreated(), sum.Counters().PropertiesSet())
		}
	}
	return nil
}

func createGroupMemberships(session neo4j.Session, rows []map[string]any, batchSize int) error {
	for i := 0; i < len(rows); i += batchSize {
		end := i + batchSize
		if end > len(rows) {
			end = len(rows)
		}
		batch := rows[i:end]

		res, err := session.Run(`
    UNWIND $rows AS r
    MERGE (u:User {id: r.client_id})
    MERGE (g:Group {id: r.group_id})
    MERGE (u)-[rel:MEMBER_OF]->(g)
`, map[string]any{"rows": batch})
		if err != nil {
			return err
		}
		sum, err := res.Consume()
		if err == nil {
			fmt.Printf("GroupMemberships batch %d..%d - RelationshipsCreated=%d\n", i, end, sum.Counters().RelationshipsCreated())
		}
	}
	return nil
}

// Вспомогательная функция для преобразования времени в timestamp в миллисекундах
func toTimestampMillis(t time.Time) int64 {
	if t.IsZero() {
		return time.Now().UnixMilli()
	}
	return t.UnixMilli()
}
