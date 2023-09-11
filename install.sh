#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if required environment variables are set
if [ -z "$API_KEY" ] || [ -z "$DOMAIN" ] || [ -z "$REFRESH_TIME" ]; then
    echo "Error: API_KEY, DOMAIN, or REFRESH_TIME environment variables are not set."
    exit 1
fi

# Your script logic here, using $API_KEY, $DOMAIN, and $REFRESH_TIME
echo "API Key: $API_KEY"
echo "Domain: $DOMAIN"
echo "Refresh Time: $REFRESH_TIME seconds"

# Function to check if a package is installed
is_package_installed() {
    if command -v "$1" &>/dev/null; then
        return 0 # Package is installed
    else
        return 1 # Package is not installed
    fi
}

# Function to install packages based on the OS
install_packages() {
    if [ "$1" == "ubuntu" ] || [ "$1" == "debian" ]; then
        # Install packages for Debian and Ubuntu
        sudo apt-get update
        sudo apt-get install -y curl jq
    elif [ "$1" == "alpine" ]; then
        # Install packages for Alpine Linux
        sudo apk update
        sudo apk add curl jq
    elif [ "$1" == "centos" ]; then
        # Install packages for CentOS
        sudo yum install -y epel-release
        sudo yum install -y curl jq
    else
        echo "Unsupported operating system: $1"
        exit 1
    fi
}

# Determine the current working directory
CURRENT_DIR="$(pwd)"

# Ask the user whether to run in Docker or on the system
read -p "Do you want to run in Docker? (yes/no): " choice

if [ "$choice" = "yes" ]; then
    # Check if Docker is installed
    if command -v docker &>/dev/null; then
        echo "Docker is installed."

        # Build and run the Docker image
        docker build -t arvan-ddns "$CURRENT_DIR"
        docker run -d --name arvan-ddns arvan-ddns
    else
        echo "Docker is not installed. Please install Docker and try again."
        exit 1
    fi
elif [ "$choice" = "no" ]; then
    # Get the operating system name
    OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')

    # Check if curl and jq are installed
    if ! is_package_installed "curl" || ! is_package_installed "jq"; then
        echo "Installing required packages (curl and jq)..."
        install_packages "$OS_NAME"
    else
        echo "curl and jq are already installed."
    fi
    # Add to crontab
    (
        crontab -l
        echo "@reboot $CURRENT_DIR/ddns-loop.sh"
    ) | crontab -
    echo "Scheduled script for execution in the system's crontab."
else
    echo "Invalid choice. Please enter 'yes' to run in Docker or 'no' to add to crontab."
    exit 1
fi
