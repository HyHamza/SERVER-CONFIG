#!/bin/bash
set -e

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

bash installers/panel.sh

export CONFIGURE_FIREWALL=true
bash installers/wings.sh
