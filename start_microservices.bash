#!/bin/bash

# Set environment variables
export DB_USERNAME='root'
export DB_PASSWORD='12345678'
export DB_HOST='127.0.0.1'
export DB_PORT='3306'
export DB_NAME='aline'
export ENCRYPT_SECRET_KEY='your_encrypt_secret_key'
export JWT_SECRET_KEY='8RbnJKvEnaBqUtKP/oBZfSkxMni7O/R65EhPJCGDEVI='  # Replace with your actual 256-bit JWT secret key

# Set service host
export APP_SERVICE_HOST='localhost'

# Set portal origins
export PORTAL_LANDING='http://localhost:4200'
export PORTAL_DASHBOARD='http://localhost:3007'
export PORTAL_ADMIN='http://localhost:3000'

# Define the function to start a microservice
start_service() {
    local service_name=$1
    local jar_name=$2
    local port=$3
    local service_dir="./$service_name"

    # Adjust the path for nested service directories
    if [[ "$service_name" != "aline-gateway" ]]; then
        service_dir="$service_dir/$service_name"
    fi

    echo "Starting $service_name on port $port"

    # Navigate to the microservice directory and run the JAR file
    (cd "$service_dir" && APP_PORT=$port java -jar "target/$jar_name") &
    sleep 10
}

# Start each microservice
start_service "user-microservice" "user-microservice-0.1.0.jar" 8070
start_service "underwriter-microservice" "underwriter-microservice-0.1.0.jar" 8071
start_service "account-microservice" "account-microservice-0.1.0.jar" 8072
start_service "transaction-microservice" "transaction-microservice-0.1.0.jar" 8073
start_service "bank-microservice" "bank-microservice-0.1.0.jar" 8083

# Start the API gateway with the correct path
start_service "aline-gateway" "aline-gateway-0.0.1-SNAPSHOT.jar" 8080

# Wait for all services to start
wait

echo "All microservices and the API Gateway have been started."
