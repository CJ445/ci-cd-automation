# CI/CD Pipeline with Docker and GitHub Actions

A complete demonstration of a Docker-based CI/CD pipeline using GitHub Actions for automated building, testing, and deployment of containerized applications.

## Features

- **Dockerized Flask Application**: Sample REST API with health checks
- **Multi-stage Docker Builds**: Optimized image size and security
- **GitHub Actions CI/CD**: Automated testing, building, and deployment
- **Automated Testing**: Unit tests with pytest and coverage reporting
- **Security Scanning**: Trivy vulnerability scanning
- **Version Management**: Image tagging with commit SHA and semantic versioning
- **Deployment Scripts**: Easy deployment and rollback mechanisms
- **Local Development**: Docker Compose for development environment

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

- Docker and Docker Compose installed
- Python 3.11+ (for local development)
- Git
- GitHub account (for CI/CD)
- DockerHub account (for image registry)

### 1. Local Development

```bash
# Clone the repository
git clone <your-repo-url>
cd ci-cd

# Install dependencies
make install

# Run tests
make test

# Start development server with Docker Compose
make run

# Access the application
curl http://localhost:5000/health
```

### 2. GitHub Setup

1. **Create GitHub Repository**
   ```bash
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Configure Secrets** (see [SECRETS_SETUP.md](SECRETS_SETUP.md))
   - Add `DOCKERHUB_USERNAME` secret
   - Add `DOCKERHUB_TOKEN` secret

3. **Trigger Pipeline**
   - Push to `main` branch triggers CI/CD
   - Create PR triggers PR checks
   - Create git tag `v*.*.*` triggers release

### 3. Testing Locally

```bash
# Build Docker image
make build

# Test the built image
make test-local

# Run production-like container
make run-prod
```

## CI/CD Pipeline

### Pipeline Stages

1. **Build and Test**
   - Checkout code
   - Install dependencies
   - Run linting (flake8)
   - Run unit tests with coverage
   - Upload coverage reports

2. **Docker Build and Push**
   - Build multi-stage Docker image
   - Run security scanning (Trivy)
   - Push to DockerHub with multiple tags
   - Test container health

3. **Create Release** (for version tags)
   - Create GitHub release
   - Attach image information

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

1. **Never commit secrets** - Use GitHub Secrets
2. **Tag releases** - Use semantic versioning (v1.0.0)
3. **Test locally** - Always test before pushing
4. **Review logs** - Check pipeline logs for issues
5. **Monitor deployments** - Verify health after deployment
6. **Keep backups** - Rollback script creates automatic backups

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

## Contributing

1. Create feature branch
2. Make changes
3. Run tests locally
4. Create pull request
5. Wait for PR checks to pass
6. Merge to main

## License

This project is for educational and demonstration purposes.
