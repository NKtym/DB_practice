# Dockerfile.go
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Копируем go.mod и go.sum (если есть)
COPY ./neo4j/go.mod ./neo4j/go.sum ./

# Скачиваем зависимости
RUN go mod download

# Копируем исходный код
COPY ./neo4j/*.go ./

# Компилируем приложение
RUN go build -o neo4j-loader load_neo4j.go

# Второй этап: создаем минимальный образ
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Копируем скомпилированный бинарник
COPY --from=builder /app/neo4j-loader .

# Копируем файл с переменными окружения (опционально)
COPY --from=builder /app/go.mod .

ENTRYPOINT ["./neo4j-loader"]