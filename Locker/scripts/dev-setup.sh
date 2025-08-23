#!/bin/bash

# development setup script
echo "Setting up development environment..."

# build development stage
echo "Building development stage..."
docker-compose build flutter-dev

# start development environment
echo "Starting development environment..."
docker-compose up -d flutter-dev

echo "Development environment is ready!"
echo "Access your app at: http://localhost:3000"
echo "To attach to the container: docker-compose exec flutter-dev bash"
echo "To view logs: docker-compose logs -f flutter-dev"