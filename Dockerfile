#phase 1
FROM ubuntu:20.04 AS builder

RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

#copies all files and directories from the build context into the builder stage. This is where the build process takes place.
COPY . .

RUN wget https://golang.org/dl/go1.19.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz

# Update the package list and install curl
RUN apt-get update && apt-get install -y curl

RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz

ENV PATH="/usr/local/go/bin:${PATH}"

RUN go build -o main main.go

#phase 2
FROM ubuntu:20.04

WORKDIR /app

# Install `wait-for-it`
RUN apt-get update && apt-get install -y wait-for-it

# migrate.linux-amd64 is generated or modified in the builder stage, thats why we are using --from=stage syntax
COPY --from=builder /app/migrate.linux-amd64 ./migrate

#copies files from the build context, specifically from the ./app/db/migration directory, into the second (final) stage.
#no need to copy from builder stage, as this is not modified/generated from/by builder stage.
COPY db/migration /app/migration

#opies the app.env file from the build context into the second stage.
COPY app.env .
EXPOSE 8080

COPY --from=builder /app/main .

# Copy your entrypoint script
COPY entrypoint.sh .

# Make the entrypoint script executable
RUN chmod +x entrypoint.sh

# Set the command to run the entrypoint script
CMD ["./entrypoint.sh"]