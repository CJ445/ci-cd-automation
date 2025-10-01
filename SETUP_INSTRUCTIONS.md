# Setup Instructions for CI/CD Automation

## Your Configuration

- **GitHub Repository**: https://github.com/CJ445/ci-cd-automation.git
- **DockerHub Repository**: https://hub.docker.com/repository/docker/cj445/ci-cd-automation/
- **DockerHub Username**: cj445

## Step 1: Configure GitHub Secrets

### Required Secrets

1. Go to your GitHub repository: https://github.com/CJ445/ci-cd-automation
2. Navigate to: **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"** and add:

#### Secret 1: DOCKERHUB_USERNAME
- **Name**: `DOCKERHUB_USERNAME`
- **Value**: `cj445`

#### Secret 2: DOCKERHUB_TOKEN
- **Name**: `DOCKERHUB_TOKEN`
- **Value**: `<your-dockerhub-access-token>`

**IMPORTANT**: After adding these secrets, you should DELETE the token from any messages or files for security.

## Step 2: Push Code to GitHub

```bash
# Navigate to project directory
cd /home/cyril/workspace/devops-ctc/summer-projects/ci-cd

# Initialize git (if not already done)
git init

# Add remote repository
git remote add origin https://github.com/CJ445/ci-cd-automation.git

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: CI/CD pipeline with Docker and GitHub Actions"

# Push to main branch
git branch -M main
git push -u origin main
```

## Step 3: Verify Pipeline

After pushing, the GitHub Actions pipeline will automatically:
1. Run tests
2. Build Docker image
3. Push to DockerHub as `cj445/ci-cd-automation:latest`

Check the pipeline status:
- GitHub: https://github.com/CJ445/ci-cd-automation/actions
- DockerHub: https://hub.docker.com/repository/docker/cj445/ci-cd-automation/

## Step 4: Test Locally (Optional)

### Test Docker Login
```bash
docker login -u cj445
# Enter your token when prompted
```

### Build and Test Locally
```bash
cd /home/cyril/workspace/devops-ctc/summer-projects/ci-cd

# Install dependencies
make install

# Run tests
make test

# Build Docker image
make build

# Test the image
make test-local
```

### Run Application
```bash
# Development mode
make run

# Production mode (local)
docker run -d -p 5000:5000 --name ci-cd-app cj445/ci-cd-automation:latest
```

## Step 5: Create Your First Release

```bash
# Make sure you're on main branch
git checkout main

# Create a version tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push the tag
git push origin v1.0.0
```

This will trigger:
- Full CI/CD pipeline
- Docker image tagged as `v1.0.0`, `v1.0`, `v1`, and `latest`
- GitHub Release creation

## Step 6: Deploy to Server

### Deploy Latest Version
```bash
./scripts/deploy.sh --tag latest
```

### Deploy Specific Version
```bash
./scripts/deploy.sh --tag v1.0.0
```

### Check Deployment
```bash
curl http://localhost:5000/health
curl http://localhost:5000/
```

## Quick Reference Commands

```bash
# Development
make install          # Install dependencies
make test            # Run tests
make run             # Start dev server
make logs            # View logs

# Docker
make build           # Build image
make test-local      # Test built image
docker pull cj445/ci-cd-automation:latest

# Deployment
./scripts/deploy.sh --tag latest
./scripts/rollback.sh --list
./scripts/rollback.sh --tag v1.0.0

# Git
git add .
git commit -m "Your message"
git push origin main
```

## Troubleshooting

### GitHub Actions Fails with Authentication Error
- Verify secrets are added correctly in GitHub repository settings
- Check that `DOCKERHUB_TOKEN` is the access token (not password)

### Cannot Push to DockerHub
- Verify repository exists: https://hub.docker.com/repository/docker/cj445/ci-cd-automation/
- Test login locally: `docker login -u cj445`

### Pipeline Doesn't Trigger
- Ensure you pushed to `main` branch
- Check GitHub Actions are enabled in repository settings

## Security Notes

1. **Never commit your DockerHub token to git**
2. The token has been provided in this session - store it securely
3. Rotate the token regularly (every 90 days recommended)
4. Use GitHub Secrets for all sensitive credentials

## Next Steps

1. ✅ Configure GitHub Secrets
2. ✅ Push code to GitHub
3. ✅ Verify pipeline runs successfully
4. ✅ Check DockerHub for built images
5. ✅ Create v1.0.0 release
6. ✅ Deploy and test

## Support

- GitHub Repository: https://github.com/CJ445/ci-cd-automation
- DockerHub: https://hub.docker.com/repository/docker/cj445/ci-cd-automation/
- Documentation: See README.md and CLAUDE.md
