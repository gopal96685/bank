# Build stage
FROM golang:latest AS builder
WORKDIR /app
COPY . .
RUN go mod init bank
RUN go mod tidy
RUN go build -o main main.go
# RUN apk --no-cache add curl
RUN apt-get install curl -y
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine:3.13
WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/migrate.linux-amd64 ./migrate
COPY app.env .
COPY entrypoint.sh .
COPY wait-for.sh .
COPY db/migration ./migration

EXPOSE 8080
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/wait-for.sh", "postgres:5432", "--", "/app/entrypoint.sh" ]
