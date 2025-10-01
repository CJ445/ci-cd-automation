# Makefile for CI/CD Demo Application
# Provides convenient commands for development and testing

.PHONY: help install test lint format build run clean deploy rollback

# Default target
help:
	@echo "Available commands:"
	@echo "  make install        - Install Python dependencies"
	@echo "  make test          - Run tests with coverage"
	@echo "  make lint          - Run linting checks"
	@echo "  make format        - Format code with black"
	@echo "  make build         - Build Docker image locally"
	@echo "  make build-dev     - Build development Docker image"
	@echo "  make run           - Run application with Docker Compose (dev)"
	@echo "  make run-prod      - Run application with Docker Compose (production)"
	@echo "  make stop          - Stop Docker Compose services"
	@echo "  make logs          - Show Docker Compose logs"
	@echo "  make shell         - Open shell in running container"
	@echo "  make clean         - Clean up containers, images, and cache"
	@echo "  make test-local    - Test Docker image locally"
	@echo "  make deploy        - Deploy using deploy script (latest)"
	@echo "  make rollback      - Show rollback options"

# Install dependencies
install:
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install flake8 black

# Run tests
test:
	pytest tests/ -v --cov=app --cov-report=term --cov-report=html

# Run quick tests
test-quick:
	pytest tests/ -v

# Run linting
lint:
	flake8 app.py tests/ --max-line-length=120

# Format code
format:
	black app.py tests/

# Build Docker image
build:
	docker build -t cicd-demo-app:local .

# Build development image
build-dev:
	docker build -f Dockerfile.dev -t cicd-demo-app:dev .

# Run with Docker Compose (development)
run:
	docker-compose up -d
	@echo "Application running at http://localhost:5000"
	@echo "View logs: make logs"

# Run production-like container
run-prod:
	docker-compose --profile production up -d app-prod
	@echo "Production container running at http://localhost:5001"

# Stop Docker Compose
stop:
	docker-compose down

# Show logs
logs:
	docker-compose logs -f

# Open shell in container
shell:
	docker-compose exec app bash

# Test built Docker image locally
test-local:
	@echo "Building image..."
	docker build -t cicd-demo-app:test .
	@echo "Starting container..."
	docker run -d -p 5002:5000 --name cicd-test cicd-demo-app:test
	@sleep 5
	@echo "Testing health endpoint..."
	curl -f http://localhost:5002/health || (docker logs cicd-test && exit 1)
	@echo "Testing home endpoint..."
	curl -f http://localhost:5002/ || (docker logs cicd-test && exit 1)
	@echo "Stopping test container..."
	docker stop cicd-test
	docker rm cicd-test
	@echo "✓ Local Docker test passed!"

# Clean up
clean:
	docker-compose down -v
	docker system prune -f
	rm -rf __pycache__ .pytest_cache htmlcov .coverage
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

# Deploy using script
deploy:
	./scripts/deploy.sh --tag latest

# Show rollback options
rollback:
	./scripts/rollback.sh --list

# Run application locally (without Docker)
run-local:
	python app.py

# Check application health
health:
	@curl -s http://localhost:5000/health | python -m json.tool || echo "Application not running"

# Show application info
info:
	@curl -s http://localhost:5000/api/info | python -m json.tool || echo "Application not running"

# Initialize git repository
git-init:
	git init
	git add .
	git commit -m "Initial commit: CI/CD pipeline setup"
	@echo "Git repository initialized"
	@echo "Next steps:"
	@echo "  1. Create GitHub repository"
	@echo "  2. git remote add origin <your-repo-url>"
	@echo "  3. git push -u origin main"
