# Quick Start Guide - CI/CD Automation

## 🎯 Your Project is Ready!

**Repository**: https://github.com/CJ445/ci-cd-automation.git
**DockerHub**: https://hub.docker.com/repository/docker/cj445/ci-cd-automation/
**Username**: cj445

---

## ⚡ Fast Track Setup (3 Steps)

### Step 1: Configure GitHub Secrets (2 minutes)

1. Visit: https://github.com/CJ445/ci-cd-automation/settings/secrets/actions
2. Click **"New repository secret"** and add these TWO secrets:

   **Secret 1:**
   - Name: `DOCKERHUB_USERNAME`
   - Value: `cj445`

   **Secret 2:**
   - Name: `DOCKERHUB_TOKEN`
   - Value: `<your-dockerhub-access-token>`

3. Click "Add secret" for each one

### Step 2: Push to GitHub (1 minute)

```bash
cd /home/cyril/workspace/devops-ctc/summer-projects/ci-cd

# Initial commit
git commit -m "Initial commit: CI/CD pipeline setup"

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

### Step 3: Watch the Magic! ✨

1. GitHub Actions will automatically start: https://github.com/CJ445/ci-cd-automation/actions
2. Pipeline will:
   - ✅ Run tests
   - ✅ Build Docker image
   - ✅ Push to DockerHub as `cj445/ci-cd-automation:latest`
   - ⏭️ **Skip** "Create Release" job (only runs for version tags)

> **💡 Note**: You'll see the "create-release" job skipped. This is normal! It only runs when you push a version tag (see below).

---

## 🧪 Test Everything Works

### 1. Pull and Run Your Image
```bash
# Pull from DockerHub
docker pull cj445/ci-cd-automation:latest

# Run the container
docker run -d -p 5000:5000 --name my-app cj445/ci-cd-automation:latest

# Test it
curl http://localhost:5000/health
curl http://localhost:5000/

# View logs
docker logs my-app

# Stop when done
docker stop my-app && docker rm my-app
```

### 2. Use Deployment Script
```bash
./scripts/deploy.sh --tag latest
```

---

## 🚀 Create Your First Release

**⚠️ This step is REQUIRED to trigger the "Create Release" job!**

The release job only runs when you push version tags. Regular pushes skip it.

```bash
# Create version tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push the tag
git push origin v1.0.0
```

This triggers:
- Full pipeline (all 3 jobs)
- Image tagged: `v1.0.0`, `v1.0`, `v1`, `latest`
- **GitHub Release created automatically** (not skipped this time!)

---

## 📋 Common Commands

```bash
# Local development
make install          # Install dependencies
make test            # Run tests
make run             # Start dev server

# Docker operations
make build           # Build image locally
make test-local      # Test built image

# Deployment
./scripts/deploy.sh --tag latest
./scripts/deploy.sh --tag v1.0.0

# Rollback
./scripts/rollback.sh --list
./scripts/rollback.sh --tag v1.0.0

# Version management
./scripts/list-versions.sh
```

---

## 📊 Monitor Your Pipeline

- **GitHub Actions**: https://github.com/CJ445/ci-cd-automation/actions
- **DockerHub Tags**: https://hub.docker.com/r/cj445/ci-cd-automation/tags
- **Releases**: https://github.com/CJ445/ci-cd-automation/releases

---

## 🎓 What You've Built

✅ **Automated CI/CD Pipeline**
- Runs on every push to main
- Automated testing with pytest
- Docker image builds with multi-stage optimization
- Security scanning with Trivy

✅ **Version Management**
- Semantic versioning (v1.0.0)
- Commit SHA tagging
- Rollback capability

✅ **Deployment Tools**
- One-command deployment
- Health checks
- Automatic backups
- Easy rollback

✅ **Best Practices**
- Non-root container user
- Multi-stage builds
- Secret management
- Comprehensive testing

---

## 🆘 Troubleshooting

### Pipeline fails with "unauthorized"
→ Check GitHub Secrets are added correctly

### Can't push to DockerHub
→ Verify token: `docker login -u cj445`

### Pipeline doesn't start
→ Ensure you pushed to `main` branch (not `master`)

---

## 📚 Documentation

- **SETUP_INSTRUCTIONS.md** - Detailed setup guide
- **README.md** - Complete project documentation
- **CLAUDE.md** - AI assistant guide
- **SECRETS_SETUP.md** - Security configuration

---

## ✅ Checklist

- [ ] Add GitHub Secrets (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN)
- [ ] Push code to GitHub (`git push -u origin main`)
- [ ] Verify pipeline runs successfully
- [ ] Check DockerHub for image
- [ ] Test pulling and running image
- [ ] Create v1.0.0 release tag
- [ ] Deploy using deployment script

**You're all set! 🎉**
