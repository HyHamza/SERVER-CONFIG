#!/bin/bash
set -e

GITHUB_BASE_URL="https://raw.githubusercontent.com/HyHamza/SERVER-CONFIG"
GITHUB_SOURCE="main"

if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed as root." >&2
  exit 1
fi

read -r -p "Enter admin username: " USERNAME
read -r -p "Enter panel FQDN: " PANEL_FQDN

ADMIN_EMAIL="${USERNAME}@talkdrove.com"
PANEL_USER_EMAIL="${USERNAME}@drove.live"
PANEL_USER_PASSWORD="admin@00"
DB_PASSWORD=$(openssl rand -base64 16)

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


# Download installer scripts to a temporary directory
TMP_DIR=$(mktemp -d)
curl -sSL -o "$TMP_DIR/panel.sh" "$GITHUB_BASE_URL/$GITHUB_SOURCE/installers/panel.sh"
curl -sSL -o "$TMP_DIR/wings.sh" "$GITHUB_BASE_URL/$GITHUB_SOURCE/installers/wings.sh"
curl -sSL -o /tmp/lib.sh "$GITHUB_BASE_URL/$GITHUB_SOURCE/lib/lib.sh"

# Ensure the installers use the correct repository
export GITHUB_BASE_URL
export GITHUB_SOURCE

# Run the installers
bash "$TMP_DIR/panel.sh"

export CONFIGURE_FIREWALL=true
bash "$TMP_DIR/wings.sh"

rm -rf "$TMP_DIR"

