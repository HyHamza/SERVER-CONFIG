#!/bin/bash
set -e

# GitHub repository configuration
GITHUB_BASE_URL="https://raw.githubusercontent.com/HyHamza/SERVER-CONFIG"
GITHUB_SOURCE="main"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed as root." >&2
  exit 1
fi

# Get user inputs
read -r -p "Enter admin username: " USERNAME
read -r -p "Enter panel FQDN: " PANEL_FQDN

# Set default values
ADMIN_EMAIL="${USERNAME}@talkdrove.com"
PANEL_USER_EMAIL="${USERNAME}@drove.live"
PANEL_USER_PASSWORD="admin@00"
DB_PASSWORD=$(openssl rand -base64 16)

# Export environment variables
export email="$ADMIN_EMAIL"
export user_email="$PANEL_USER_EMAIL"
export user_username="$USERNAME"
export user_firstname="$USERNAME"
export user_lastname="$USERNAME"
export user_password="$PANEL_USER_PASSWORD"
export FQDN="$PANEL_FQDN"
export timezone="Asia/Karachi"
export CONFIGURE_LETSENCRYPT=true
export ASSUME_SSL=false
export CONFIGURE_FIREWALL=true
export MYSQL_DB="HTD"
export MYSQL_USER="SERVER"
export MYSQL_PASSWORD="$DB_PASSWORD"

# Export GitHub configuration for installers
export GITHUB_BASE_URL
export GITHUB_SOURCE

echo "* Downloading installer scripts from GitHub..."

# Create temporary directory for downloads
TMP_DIR=$(mktemp -d)
echo "* Created temporary directory: $TMP_DIR"

# Download installer scripts
echo "* Downloading panel.sh..."
curl -sSL -o "$TMP_DIR/panel.sh" "$GITHUB_BASE_URL/$GITHUB_SOURCE/installers/panel.sh"

echo "* Downloading wings.sh..."
curl -sSL -o "$TMP_DIR/wings.sh" "$GITHUB_BASE_URL/$GITHUB_SOURCE/installers/wings.sh"

echo "* Downloading lib.sh..."
curl -sSL -o "$TMP_DIR/lib.sh" "$GITHUB_BASE_URL/$GITHUB_SOURCE/lib/lib.sh"

# Verify downloads
if [[ ! -f "$TMP_DIR/panel.sh" ]] || [[ ! -f "$TMP_DIR/wings.sh" ]] || [[ ! -f "$TMP_DIR/lib.sh" ]]; then
    echo "* Error: Failed to download required files from GitHub" >&2
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "* All files downloaded successfully"

# Make scripts executable
chmod +x "$TMP_DIR/panel.sh"
chmod +x "$TMP_DIR/wings.sh"

echo "* Starting panel installation..."
bash "$TMP_DIR/panel.sh"

echo "* Starting wings installation..."
export CONFIGURE_FIREWALL=true
bash "$TMP_DIR/wings.sh"

echo "* Installation completed successfully"
echo "* Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "* Setup complete!"
echo "* Admin Email: $ADMIN_EMAIL"
echo "* Panel FQDN: $PANEL_FQDN"
echo "* Database Password: $DB_PASSWORD"