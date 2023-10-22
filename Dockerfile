#phase 1
FROM ubuntu:20.04 AS builder

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN wget https://golang.org/dl/go1.19.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

RUN go build -o main main.go

#phase 2

FROM ubuntu:20.04 

WORKDIR /app

COPY --from=builder /app/main .
COPY app.env .

EXPOSE 8080

CMD ["/app/main"]