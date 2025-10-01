# GitHub Secrets Configuration Guide

This document explains how to set up the required secrets for the CI/CD pipeline to work with DockerHub.

## Required Secrets

The GitHub Actions workflow requires the following secrets to be configured in your repository:

### 1. DOCKERHUB_USERNAME
- **Description**: Your DockerHub username
- **Example**: `myusername`
- **Used for**: Authenticating to DockerHub and tagging images

### 2. DOCKERHUB_TOKEN
- **Description**: DockerHub Access Token (NOT your password)
- **How to create**:
  1. Log in to [DockerHub](https://hub.docker.com/)
  2. Go to Account Settings → Security
  3. Click "New Access Token"
  4. Enter a description (e.g., "GitHub Actions CI/CD")
  5. Set permissions to "Read, Write, Delete"
  6. Copy the generated token (you won't see it again!)

### 3. GITHUB_TOKEN (Automatic)
- **Description**: Automatically provided by GitHub Actions
- **No configuration needed**: This is automatically available in workflows
- **Used for**: Creating releases and interacting with GitHub API

## How to Add Secrets to GitHub Repository

### Step-by-Step Instructions:

1. **Navigate to your repository on GitHub**

2. **Go to Settings**
   - Click on the "Settings" tab in your repository

3. **Access Secrets and Variables**
   - In the left sidebar, click "Secrets and variables"
   - Click "Actions"

4. **Add New Repository Secret**
   - Click the "New repository secret" button
   - Enter the secret name (e.g., `DOCKERHUB_USERNAME`)
   - Enter the secret value
   - Click "Add secret"

5. **Repeat for all required secrets**
   - Add `DOCKERHUB_USERNAME`
   - Add `DOCKERHUB_TOKEN`

## Security Best Practices

### DO:
✅ Use DockerHub Access Tokens instead of passwords
✅ Create tokens with minimal required permissions
✅ Rotate tokens regularly (every 90 days recommended)
✅ Delete tokens that are no longer needed
✅ Use different tokens for different projects/environments
✅ Store secrets only in GitHub Secrets (never in code)

### DON'T:
❌ Never commit secrets to your repository
❌ Never expose secrets in logs or outputs
❌ Never share tokens via email or messaging
❌ Never use your DockerHub password directly
❌ Never grant more permissions than necessary

## Verifying Secrets Configuration

After adding secrets, you can verify they're configured correctly:

1. Go to your repository's "Settings" → "Secrets and variables" → "Actions"
2. You should see the secrets listed (values are hidden)
3. Trigger a workflow run (push to main branch)
4. Check the workflow logs for successful authentication

### Expected Workflow Output:
```
Login to Docker Hub
✓ Logged in successfully
```

## Alternative: Using GitHub Container Registry (GHCR)

If you prefer to use GitHub Container Registry instead of DockerHub:

1. No additional secrets needed (uses GITHUB_TOKEN)
2. Update workflow to use `ghcr.io` registry
3. Images stored at: `ghcr.io/username/repo-name`

### Example modification in workflow:
```yaml
env:
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: ghcr.io/${{ github.repository_owner }}/cicd-demo-app

- name: Log in to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

## Troubleshooting

### Error: "unauthorized: authentication required"
- **Cause**: Secrets not configured or incorrect credentials
- **Solution**: Verify secrets are added correctly and token is valid

### Error: "denied: requested access to the resource is denied"
- **Cause**: Token doesn't have write permissions
- **Solution**: Recreate token with "Read, Write, Delete" permissions

### Error: "Image name is invalid"
- **Cause**: DOCKERHUB_USERNAME not set correctly
- **Solution**: Ensure username matches your DockerHub account exactly

## Testing Secrets Locally

**IMPORTANT**: Never test with real secrets locally. For local development:

1. Use `.env` file (add to `.gitignore`)
2. Use Docker Compose for local builds
3. Test workflow logic with `act` tool (GitHub Actions local runner)

## Secret Rotation Plan

Recommended schedule:
- **Every 90 days**: Rotate DockerHub tokens
- **Immediately**: If token is suspected to be compromised
- **After team member departure**: Rotate all shared credentials

## Additional Resources

- [GitHub Encrypted Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [DockerHub Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [Docker Login Action](https://github.com/docker/login-action)
