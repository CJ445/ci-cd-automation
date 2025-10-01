# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Docker-based CI/CD Pipeline** project demonstrating automated build, test, and deployment workflows using GitHub Actions. The project features a Flask REST API application containerized with Docker and deployed to DockerHub with comprehensive testing, security scanning, and rollback capabilities.

## Architecture

### Application Layer
- **Flask REST API** (`app.py`): Simple web service with health checks, echo endpoint, and version information
- **Multi-stage Docker build**: Optimized for production with security best practices
- **Development environment**: Hot-reload capable Docker Compose setup

### CI/CD Pipeline
- **GitHub Actions workflows**: Automated on push, PR, and tag events
- **Three-stage pipeline**:
  1. Build and Test (pytest with coverage)
  2. Docker Build and Push (multi-tag strategy)
  3. Release Creation (for version tags only)

### Deployment Strategy
- **Image tagging**: latest, commit SHA, semantic versioning (v1.0.0)
- **Registry**: DockerHub (configurable to GHCR)
- **Rollback mechanism**: Version-based with automatic backup

## Common Commands

### Development Workflow

```bash
# Initial setup
make install                    # Install Python dependencies
make test                       # Run pytest with coverage
make lint                       # Run flake8 linting
make format                     # Format with black

# Docker local development
make run                        # Start dev server (http://localhost:5000)
make logs                       # View container logs
make stop                       # Stop all containers
make shell                      # Open shell in container

# Build and test Docker images
make build                      # Build production image locally
make build-dev                  # Build development image
make test-local                 # Build and test image with health checks
make run-prod                   # Run production-like container (port 5001)
```

### Testing

```bash
# Run all tests with coverage
pytest tests/ -v --cov=app --cov-report=html

# Run specific test file
pytest tests/test_app.py -v

# Quick test run
make test-quick

# Test coverage report
open htmlcov/index.html
```

### Deployment and Rollback

```bash
# Deploy latest version
./scripts/deploy.sh --tag latest

# Deploy specific version
./scripts/deploy.sh --tag v1.0.0 --port 5000

# List available versions
./scripts/rollback.sh --list
./scripts/list-versions.sh

# Check current running version
./scripts/rollback.sh --current

# Rollback to previous version
./scripts/rollback.sh --tag v1.0.0
```

### Git and GitHub Workflow

```bash
# Create release with semantic version
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0          # Triggers full CI/CD + GitHub release

# Regular development
git push origin main            # Triggers full pipeline + Docker push
git push origin develop         # Triggers build/test only

# Create pull request
# PR automatically triggers pr-check.yml workflow
```

### Docker Commands

```bash
# Manual Docker operations
docker build -t cicd-demo-app:local .
docker run -d -p 5000:5000 --name test-app cicd-demo-app:local
docker logs test-app -f
docker exec -it test-app bash

# Docker Compose operations
docker-compose up -d
docker-compose logs -f app
docker-compose exec app python -c "import app; print(app.VERSION)"
docker-compose down -v
```

## Key Configuration Files

### GitHub Actions Workflows

**`.github/workflows/ci-cd-pipeline.yml`**: Main CI/CD pipeline
- Triggered on: push to main/develop, tags v*.*.*
- Jobs: build-and-test → docker-build-push → create-release
- Secrets required: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`
- Features: pytest, coverage, Trivy scanning, multi-tag strategy

**`.github/workflows/pr-check.yml`**: Pull request validation
- Triggered on: pull requests to main/develop
- Jobs: lint-test, docker-build-test (no push)
- Validates code quality before merge

### Docker Configuration

**`Dockerfile`**: Production multi-stage build
- Stage 1: Builder with gcc for compilations
- Stage 2: Runtime with python:3.11-slim
- Non-root user (appuser, uid 1000)
- Gunicorn with 4 workers
- Healthcheck every 30s

**`Dockerfile.dev`**: Development build
- Single-stage for faster rebuilds
- Flask development server with hot-reload
- Debug mode enabled

**`docker-compose.yml`**: Local development orchestration
- Service `app`: Development container with volume mounting
- Service `app-prod`: Production-like container (profile: production)
- Auto-restart enabled

### Application Code

**`app.py`**: Flask application (main logic at lines 1-75)
- Environment variables: `APP_VERSION`, `BUILD_SHA`, `ENVIRONMENT`, `PORT`
- Endpoints:
  - `GET /`: App info with version
  - `GET /health`: Health check (200 OK)
  - `POST /api/echo`: Echo posted JSON
  - `GET /api/info`: Detailed system info
- Error handlers: 404, 500

**`tests/test_app.py`**: Unit tests
- Test classes for each endpoint
- Coverage target: All endpoints and error handlers
- Uses pytest fixtures for Flask test client

### Deployment Scripts

**`scripts/deploy.sh`**: Deployment automation
- Pulls specified image tag from DockerHub
- Stops existing container gracefully
- Starts new container with health checks
- Validates deployment success (10 attempts)
- Usage: `--tag TAG`, `--port PORT`, `--name NAME`

**`scripts/rollback.sh`**: Rollback mechanism
- Creates automatic backup before rollback
- Pulls and deploys previous version
- Health check validation
- Auto-restore backup on failure
- Usage: `--tag TAG`, `--list`, `--current`

**`scripts/list-versions.sh`**: Version management
- Lists local Docker images
- Fetches DockerHub tags (requires curl + jq)

## Important Implementation Details

### Image Tagging Strategy

The pipeline creates multiple tags for each build:
```yaml
# .github/workflows/ci-cd-pipeline.yml:65-77
tags:
  - type=ref,event=branch          # main, develop
  - type=semver,pattern={{version}} # v1.0.0
  - type=semver,pattern={{major}}.{{minor}} # v1.0
  - type=sha,prefix={{branch}}-    # main-abc123f
  - type=raw,value=latest          # latest (main only)
```

### Multi-stage Docker Build

Dockerfile uses builder pattern for optimal size:
- Builder stage: Installs gcc, compiles dependencies
- Runtime stage: Copies only compiled dependencies
- Reduces final image size by ~40%
- See `Dockerfile:1-20` (builder) and `Dockerfile:22-55` (runtime)

### Security Features

1. **Non-root execution**: User `appuser` (uid 1000) at `Dockerfile:28-31`
2. **Secret management**: GitHub Secrets (never in code)
3. **Vulnerability scanning**: Trivy in `ci-cd-pipeline.yml:117-125`
4. **Minimal base**: python:3.11-slim (not full python image)
5. **No credential caching**: `--no-cache-dir` in pip installs

### Health Check Implementation

- Container-level: `Dockerfile:48-50` (30s interval)
- Application-level: `/health` endpoint in `app.py:19-26`
- Deployment validation: `scripts/deploy.sh:72-89` (10 attempts)

### Environment Variables

Application reads from environment:
- `APP_VERSION`: Version string (default: "1.0.0")
- `BUILD_SHA`: Git commit SHA (set by GitHub Actions)
- `ENVIRONMENT`: production/development
- `PORT`: Listen port (default: 5000)

Set in GitHub Actions: `ci-cd-pipeline.yml:111-113`

### GitHub Secrets Setup

Required secrets (see `SECRETS_SETUP.md`):
1. Navigate to: Repository → Settings → Secrets and variables → Actions
2. Add secrets:
   - `DOCKERHUB_USERNAME`: DockerHub account name
   - `DOCKERHUB_TOKEN`: Access token (NOT password)

Create DockerHub token at: https://hub.docker.com/ → Account Settings → Security

### Workflow Triggers

```yaml
# Push to main/develop
on:
  push:
    branches: [main, develop]
    tags: ['v*.*.*']
  pull_request:
    branches: [main, develop]
```

- **Push to main**: Full pipeline + Docker push + latest tag
- **Push to develop**: Build/test only (no Docker push)
- **Pull request**: Linting, testing, Docker build validation
- **Tag v*.*.***: Full pipeline + GitHub release creation

### Test Structure

Tests use pytest with fixtures:
- `tests/conftest.py`: Path setup for imports
- `tests/test_app.py`: Test classes by endpoint
- Coverage includes: endpoints, JSON responses, error handlers
- Run with: `pytest tests/ -v --cov=app`

## Development Workflow

### Adding New Endpoints

1. Add endpoint function to `app.py`
2. Create test class in `tests/test_app.py`
3. Run tests: `make test`
4. Verify locally: `make run` → `curl http://localhost:5000/endpoint`
5. Create PR (triggers PR checks)
6. Merge to main (triggers deployment)

### Modifying Docker Build

1. Edit `Dockerfile` (production) or `Dockerfile.dev` (development)
2. Test locally: `make build && make test-local`
3. Verify in compose: `make run-prod`
4. Push to trigger pipeline rebuild

### Creating a Release

1. Update version in code if needed
2. Commit changes: `git commit -am "Prepare v1.0.0 release"`
3. Create tag: `git tag -a v1.0.0 -m "Release v1.0.0"`
4. Push tag: `git push origin v1.0.0`
5. GitHub Actions creates release automatically
6. Image available at: `dockerhub.com/r/USERNAME/cicd-demo-app:v1.0.0`

### Switching to GitHub Container Registry (GHCR)

To use GHCR instead of DockerHub:

1. Edit `.github/workflows/ci-cd-pipeline.yml`:
   ```yaml
   env:
     DOCKER_REGISTRY: ghcr.io
     IMAGE_NAME: ghcr.io/${{ github.repository_owner }}/cicd-demo-app
   ```

2. Update login action (line 91-95):
   ```yaml
   - name: Log in to GitHub Container Registry
     uses: docker/login-action@v3
     with:
       registry: ghcr.io
       username: ${{ github.actor }}
       password: ${{ secrets.GITHUB_TOKEN }}
   ```

3. No additional secrets needed (uses GITHUB_TOKEN)

## Troubleshooting

### Pipeline Fails: "unauthorized: authentication required"
- **Cause**: DockerHub secrets not configured
- **Fix**: Add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` in repo settings
- **Verify**: Settings → Secrets and variables → Actions

### Container Health Check Fails
- **Cause**: Port conflict or application crash
- **Fix**: Check logs: `docker logs <container-name>`
- **Debug**: `docker exec -it <container-name> bash`
- **Verify port**: `netstat -tulpn | grep 5000`

### Tests Fail Locally
- **Cause**: Missing dependencies or wrong Python version
- **Fix**: `make install` and verify Python 3.11+
- **Debug**: Run with verbose: `pytest tests/ -v -s`

### Docker Build Slow
- **Cause**: Layer cache invalidation
- **Fix**: GitHub Actions uses registry cache (see `ci-cd-pipeline.yml:110-111`)
- **Local**: Use BuildKit: `DOCKER_BUILDKIT=1 docker build .`

### Rollback Fails
- **Cause**: Old image not available locally/remotely
- **Fix**: Check available tags: `./scripts/list-versions.sh`
- **Manual**: `docker pull <image>:<tag>` then `./scripts/rollback.sh --tag <tag>`

## Code Locations

### Application Logic
- `app.py:14-22`: Home endpoint with version info
- `app.py:24-31`: Health check endpoint
- `app.py:33-40`: Echo endpoint (POST)
- `app.py:42-54`: Info endpoint (system details)
- `app.py:56-69`: Error handlers (404, 500)

### CI/CD Pipeline
- `.github/workflows/ci-cd-pipeline.yml:18-49`: Build and test job
- `.github/workflows/ci-cd-pipeline.yml:51-160`: Docker build/push job
- `.github/workflows/ci-cd-pipeline.yml:162-192`: Release creation job

### Deployment Scripts
- `scripts/deploy.sh:47-92`: Main deployment logic
- `scripts/rollback.sh:95-165`: Rollback with backup
- `scripts/rollback.sh:167-180`: Backup restoration

### Testing
- `tests/test_app.py:10-36`: Home endpoint tests
- `tests/test_app.py:38-54`: Health endpoint tests
- `tests/test_app.py:56-76`: Echo endpoint tests
- `tests/test_app.py:96-106`: Error handler tests

## Best Practices

1. **Always test locally** before pushing: `make test-local`
2. **Use semantic versioning**: v1.0.0 for releases
3. **Never commit secrets**: Use GitHub Secrets and `.env` (gitignored)
4. **Verify deployments**: Check health endpoint after deploy
5. **Tag images properly**: Use commit SHA for traceability
6. **Monitor pipelines**: Review GitHub Actions logs for issues
7. **Keep backups**: Rollback script auto-creates backups
8. **Update dependencies**: Regular `pip list --outdated` checks
