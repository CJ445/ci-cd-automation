# CI/CD Automation

Automated CI/CD pipeline with Docker and GitHub Actions.

## Overview

This project demonstrates:
- Containerized Python Flask application
- Automated testing and deployment
- Docker image building and pushing to DockerHub
- Version tagging and releases

## Setup

### Prerequisites
- Docker
- Python 3.11+
- GitHub account
- DockerHub account

### GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

- `DOCKERHUB_USERNAME` - Your DockerHub username
- `DOCKERHUB_TOKEN` - DockerHub access token (create at hub.docker.com → Account Settings → Security)

## Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run tests
pytest tests/ -v

# Run app locally
python app.py

# Or use Docker
docker-compose up
```

## Build and Test

```bash
# Build Docker image
docker build -t myapp .

# Run container
docker run -p 5000:5000 myapp

# Test endpoints
curl http://localhost:5000/health
curl http://localhost:5000/
```

## CI/CD Pipeline

The GitHub Actions workflow runs on every push to `main`:

1. **Test** - Runs pytest
2. **Build** - Creates Docker image
3. **Push** - Uploads to DockerHub

### Creating Releases

Push a version tag to create a GitHub release:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

This creates multiple Docker tags:
- `v1.0.0`
- `v1.0`
- `v1`
- `latest`

## Deployment

```bash
# Deploy latest version
./scripts/deploy.sh --tag latest

# Deploy specific version
./scripts/deploy.sh --tag v1.0.0

# Rollback to previous version
./scripts/rollback.sh --tag v1.0.0
```

## Project Structure

```
.
├── app.py                    # Flask application
├── Dockerfile                # Production container
├── Dockerfile.dev            # Development container
├── docker-compose.yml        # Local development setup
├── requirements.txt          # Python dependencies
├── .github/workflows/        # CI/CD pipelines
│   ├── ci-cd-pipeline.yml   # Main pipeline
│   └── pr-check.yml         # PR validation
├── tests/                    # Unit tests
└── scripts/                  # Deployment scripts
```

## API Endpoints

- `GET /` - Application info
- `GET /health` - Health check
- `GET /api/info` - System information
- `POST /api/echo` - Echo JSON payload

## Troubleshooting

**Pipeline fails:**
- Check GitHub secrets are configured
- Verify DockerHub token is valid

**Container won't start:**
- Check logs: `docker logs <container-name>`
- Verify port 5000 isn't in use

**Tests fail:**
- Run locally: `pytest tests/ -v`
- Check Python version: `python --version`
