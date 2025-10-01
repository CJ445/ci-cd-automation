#!/bin/bash
# Script to push code to GitHub
# This script helps with authentication

echo "🚀 Pushing code to GitHub..."
echo ""
echo "Repository: https://github.com/CJ445/ci-cd-automation.git"
echo ""

# Option 1: Using GitHub CLI (recommended if installed)
if command -v gh &> /dev/null; then
    echo "Using GitHub CLI..."
    gh auth login
    git push -u origin main
    exit 0
fi

# Option 2: Using Personal Access Token
echo "To push to GitHub, you have these options:"
echo ""
echo "Option 1: Use GitHub CLI (recommended)"
echo "  sudo apt install gh"
echo "  gh auth login"
echo "  git push -u origin main"
echo ""
echo "Option 2: Use SSH (recommended)"
echo "  # Set up SSH key"
echo "  ssh-keygen -t ed25519 -C 'your_email@example.com'"
echo "  cat ~/.ssh/id_ed25519.pub  # Add this to GitHub"
echo "  git remote set-url origin git@github.com:CJ445/ci-cd-automation.git"
echo "  git push -u origin main"
echo ""
echo "Option 3: Use Personal Access Token"
echo "  # Create token at: https://github.com/settings/tokens"
echo "  # Then run:"
echo "  git push -u origin main"
echo "  # Username: CJ445"
echo "  # Password: <your-personal-access-token>"
echo ""
echo "Option 4: Use HTTPS with credential helper"
echo "  git config --global credential.helper store"
echo "  git push -u origin main"
echo "  # Enter your credentials once, they'll be saved"
