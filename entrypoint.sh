#!/bin/bash

# Wait for the database to be ready
wait-for-it -t 0 postgres:5432

# Run the migrate command
./migrate -path migration -database "postgresql://root:secret@postgres:5432/simple_bank?sslmode=disable" -verbose up

# Start your application
./main
