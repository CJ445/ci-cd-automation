# CI/CD Automation with Docker & GitHub Actions

Automated CI/CD pipeline for containerized applications using Docker and GitHub Actions.

## Features

- Dockerized Flask REST API with health checks
- Multi-stage Docker builds for optimized images
- Automated CI/CD with GitHub Actions
- Unit testing with pytest
- Security scanning with Trivy
- Semantic versioning and image tagging
- Deployment and rollback scripts
- Docker Compose for local development

## Project Structure

```
ci-cd/
├── .github/
│   └── workflows/
│       ├── ci-cd-pipeline.yml    # Main CI/CD workflow
│       └── pr-check.yml          # Pull request checks
├── scripts/
│   ├── deploy.sh                 # Deployment script
│   ├── rollback.sh               # Rollback script
│   └── list-versions.sh          # List available versions
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_app.py               # Unit tests
├── app.py                        # Flask application
├── Dockerfile                    # Production Dockerfile
├── Dockerfile.dev                # Development Dockerfile
├── docker-compose.yml            # Local development setup
├── requirements.txt              # Python dependencies
├── Makefile                      # Convenient commands
├── SECRETS_SETUP.md             # GitHub secrets guide
└── README.md                     # This file
```

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Python 3.11+
- Git
- GitHub account
- DockerHub account

### Local Development

```bash
# Clone repository
git clone https://github.com/CJ445/ci-cd-automation.git
cd ci-cd-automation

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest tests/

# Start development server
docker-compose up
```

### GitHub Actions Setup

1. Fork/Clone this repository
2. Add GitHub Secrets:
   - `DOCKERHUB_USERNAME`: Your DockerHub username
   - `DOCKERHUB_TOKEN`: DockerHub access token
3. Push to main branch to trigger pipeline

## CI/CD Pipeline

### Pipeline Stages

1. **Build and Test** ✅ (Runs on every push/PR)
   - Checkout code
   - Install dependencies
   - Run linting (flake8)
   - Run unit tests with coverage
   - Upload coverage reports

2. **Docker Build and Push** ✅ (Runs on push to main/develop)
   - Build multi-stage Docker image
   - Run security scanning (Trivy)
   - Push to DockerHub with multiple tags
   - Test container health

3. **Create Release** ⚠️ (Only runs when pushing version tags like `v1.0.0`)
   - Create GitHub release
   - Attach image information
   - **Note**: This job is SKIPPED on regular pushes to main

### Image Tagging Strategy

Images are tagged with:
- `latest`: Latest stable build from main branch
- `main-<sha>`: Commit SHA from main branch
- `v1.0.0`: Semantic version from git tags
- `v1.0`, `v1`: Major/minor versions

### Workflow Triggers

- **Push to `main`**: Full CI/CD pipeline + Docker push
- **Push to `develop`**: Build and test only
- **Pull Request**: Linting, testing, Docker build (no push)
- **Git Tag `v*.*.*`**: Full pipeline + GitHub release

> **⚠️ Important**: The "Create Release" job only runs when you push a version tag (e.g., `v1.0.0`). Regular pushes to `main` will skip this job. To trigger a release, you must create and push a git tag.

## Deployment

### Deploy Latest Version

```bash
./scripts/deploy.sh --tag latest
```

### Deploy Specific Version

```bash
./scripts/deploy.sh --tag v1.0.0
```

### Custom Port

```bash
./scripts/deploy.sh --tag latest --port 8080
```

## Rollback

### List Available Versions

```bash
./scripts/rollback.sh --list
```

### Check Current Version

```bash
./scripts/rollback.sh --current
```

### Rollback to Previous Version

```bash
./scripts/rollback.sh --tag v1.0.0
```

The rollback script:
- Creates automatic backup before rollback
- Performs health checks
- Auto-restores backup if rollback fails

## API Endpoints

- `GET /` - Application information
- `GET /health` - Health check endpoint
- `GET /api/info` - Detailed system information
- `POST /api/echo` - Echo endpoint for testing

### Examples

```bash
# Health check
curl http://localhost:5000/health

# Get application info
curl http://localhost:5000/

# Test echo endpoint
curl -X POST http://localhost:5000/api/echo \
  -H "Content-Type: application/json" \
  -d '{"message": "hello"}'
```

## Development Commands

```bash
# Install dependencies
make install

# Run tests
make test

# Run linting
make lint

# Format code
make format

# Build Docker image
make build

# Run development server
make run

# View logs
make logs

# Stop services
make stop

# Clean up
make clean
```

## Testing

### Run All Tests

```bash
make test
```

### Run Tests with Coverage

```bash
pytest tests/ -v --cov=app --cov-report=html
```

### View Coverage Report

```bash
open htmlcov/index.html
```

## Security

- **Multi-stage builds**: Separate build and runtime dependencies
- **Non-root user**: Application runs as non-privileged user
- **Secrets management**: GitHub Secrets for credentials
- **Vulnerability scanning**: Automated Trivy scanning
- **Minimal base image**: Python slim for reduced attack surface

## Monitoring

### Check Application Health

```bash
make health
```

### View Container Logs

```bash
docker logs cicd-demo-app -f
```

### Container Stats

```bash
docker stats cicd-demo-app
```

## Troubleshooting

### Pipeline Fails on DockerHub Authentication

- Verify secrets are configured correctly
- Ensure DockerHub token has write permissions
- Check token hasn't expired

### Container Health Check Fails

- Check container logs: `docker logs <container-name>`
- Verify port mapping is correct
- Ensure no port conflicts

### Tests Fail Locally

- Install dependencies: `make install`
- Check Python version: `python --version`
- Run with verbose output: `pytest tests/ -v`

## Best Practices

- Never commit secrets - use GitHub Secrets
- Use semantic versioning for releases (v1.0.0)
- Test locally before pushing
- Monitor pipeline logs
- Verify deployments with health checks

## Version Management

### Creating a Release

```bash
# Tag the commit
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push tag to trigger release pipeline
git push origin v1.0.0
```

### Versioning Strategy

- **Major version** (v1.0.0 → v2.0.0): Breaking changes
- **Minor version** (v1.0.0 → v1.1.0): New features
- **Patch version** (v1.0.0 → v1.0.1): Bug fixes

## License

MIT License - See LICENSE file for details.
