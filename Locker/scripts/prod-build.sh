#!/bin/bash

# production build script
echo "Building production environment..."

# building production stage
docker-compose --profile production build flutter-prod

# start production environment
docker-compose --profile production up -d flutter-prod

echo "Production environment is ready!"
echo "Access your app at: http://localhost:8080"
