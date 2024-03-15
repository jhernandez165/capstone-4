#!/bin/bash

# Function to stop a microservice
stop_service() {
    local service_name=$1
    local jar_name=$2

    echo "Stopping $service_name..."

    # Find the process ID (PID) of the service using the jar name and kill the process
    pid=$(ps aux | grep "$jar_name" | grep -v grep | awk '{print $2}')
    
    if [ ! -z "$pid" ]; then
        kill "$pid"
        echo "$service_name stopped."
    else
        echo "$service_name is not running or could not be found."
    fi
}

# Stop each microservice
stop_service "user-microservice" "user-microservice-0.1.0.jar"
stop_service "underwriter-microservice" "underwriter-microservice-0.1.0.jar"
stop_service "account-microservice" "account-microservice-0.1.0.jar"
stop_service "transaction-microservice" "transaction-microservice-0.1.0.jar"
stop_service "bank-microservice" "bank-microservice-0.1.0.jar"
stop_service "aline-gateway" "aline-gateway-0.0.1-SNAPSHOT.jar"

echo "All microservices and the API Gateway have been stopped."
