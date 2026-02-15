FROM golang:1.25-alpine AS builder
WORKDIR /app
COPY ./neo4j/go.mod ./neo4j/go.sum ./
RUN go mod download
COPY ./neo4j/*.go ./
RUN go build -o neo4j-loader load_neo4j.go
FROM alpine:latest
RUN apk --no-cache add
WORKDIR /app
COPY --from=builder /app/neo4j-loader .
COPY --from=builder /app/go.mod .
ENTRYPOINT ["./neo4j-loader"]
