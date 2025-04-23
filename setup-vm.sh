#!/bin/bash

# Exit on error
set -e

# Function to check if Git is installed
install_git() {
    if ! command -v git &> /dev/null; then
        echo "Git not found. Installing..."
        sudo apt update && sudo apt install -y git
    else
        echo "Git is already installed."
    fi
}

# Function to configure Git user details
configure_git() {
    GIT_USER="your_github_username"  # Replace with your GitHub username
    GIT_EMAIL="your_email@example.com"  # Replace with your GitHub email

    echo "Configuring Git with username: $GIT_USER and email: $GIT_EMAIL"
    git config --global user.name "$GIT_USER"
    git config --global user.email "$GIT_EMAIL"
}

# Function to check SSH keys and configure GitHub authentication
setup_github_ssh() {
    SSH_KEY="$HOME/.ssh/id_rsa"

    if [ ! -f "$SSH_KEY" ]; then
        echo "No SSH key found. Generating a new one..."
        ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
        eval "$(ssh-agent -s)"
        ssh-add "$SSH_KEY"

        echo "Your new SSH key:"
        cat "$SSH_KEY.pub"
        echo "Add this key to GitHub: https://github.com/settings/keys"
        read -p "Press enter after adding the SSH key to GitHub..."
    else
        echo "SSH key already exists."
    fi

    echo "Testing GitHub SSH connection..."
    ssh -T git@github.com
}

# Function to clone the repository
clone_repo() {
    REPO_URL="git@github.com:iankonradjohnson/Real-ESRGAN.git"
    TARGET_DIR="Real-ESRGAN"

    if [ -d "$TARGET_DIR" ]; then
        echo "Repository already exists in $TARGET_DIR. Pulling latest changes..."
        cd "$TARGET_DIR" && git pull
    else
        echo "Cloning repository: $REPO_URL"
        git clone "$REPO_URL"
    fi
}

# Run functions
install_git
configure_git
setup_github_ssh
clone_repo

echo "✅ Git setup and repository clone completed successfully!"
