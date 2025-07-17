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
# Menu for installation or uninstallation
echo "Select an option:"
echo "  1) Install panel"
echo "  2) Install wings"
echo "  3) Install panel and wings"
echo "  4) Uninstall panel or wings"
read -r -p "Enter choice [1-4]: " ACTION

INSTALL_PANEL=false
INSTALL_WINGS=false
DO_UNINSTALL=false

case "$ACTION" in
  1)
    INSTALL_PANEL=true
    ;;
  2)
    INSTALL_WINGS=true
    ;;
  3)
    INSTALL_PANEL=true
    INSTALL_WINGS=true
    ;;
  4)
    DO_UNINSTALL=true
    ;;
  *)
    echo "* Invalid choice" >&2
    exit 1
    ;;
esac

if [[ "$DO_UNINSTALL" != true ]]; then
  read -r -p "Enter admin username: " USERNAME
  [[ "$INSTALL_PANEL" == true ]] && read -r -p "Enter panel FQDN: " PANEL_FQDN
  [[ "$INSTALL_WINGS" == true ]] && read -r -p "Enter wings FQDN: " WINGS_FQDN
else
  echo "What do you want to uninstall?"
  echo "  1) Panel"
  echo "  2) Wings"
  echo "  3) Both"
  read -r -p "Enter choice [1-3]: " UN_CHOICE
  case "$UN_CHOICE" in
    1)
      export RM_PANEL=true
      export RM_WINGS=false
      ;;
    2)
      export RM_PANEL=false
      export RM_WINGS=true
      ;;
    3)
      export RM_PANEL=true
      export RM_WINGS=true
      ;;
    *)
      echo "* Invalid choice" >&2
      exit 1
      ;;
  esac
fi


if [[ "$DO_UNINSTALL" != true ]]; then
  # Set default values
  ADMIN_EMAIL="${USERNAME}@talkdrove.com"
  PANEL_USER_EMAIL="${USERNAME}@drove.live"
  PANEL_USER_PASSWORD="admin@00"
  DB_PASSWORD=$(openssl rand -base64 16)

  # Panel environment
  export email="$ADMIN_EMAIL"
  export user_email="$PANEL_USER_EMAIL"
  export user_username="$USERNAME"
  export user_firstname="$USERNAME"
  export user_lastname="$USERNAME"
  export user_password="$PANEL_USER_PASSWORD"
  export timezone="Asia/Karachi"
  export CONFIGURE_LETSENCRYPT=true
  export ASSUME_SSL=false
  export CONFIGURE_FIREWALL=true
  export MYSQL_DB="HTD"
  export MYSQL_USER="SERVER"
  export MYSQL_PASSWORD="$DB_PASSWORD"
fi

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

echo "* Downloading uninstall.sh..."
curl -sSL -o "$TMP_DIR/uninstall.sh" "$GITHUB_BASE_URL/$GITHUB_SOURCE/installers/uninstall.sh"

echo "* Downloading lib.sh..."
curl -sSL -o "$TMP_DIR/lib.sh" "$GITHUB_BASE_URL/$GITHUB_SOURCE/lib/lib.sh"

# Verify downloads
if [[ ! -f "$TMP_DIR/panel.sh" ]] || [[ ! -f "$TMP_DIR/wings.sh" ]] || [[ ! -f "$TMP_DIR/uninstall.sh" ]] || [[ ! -f "$TMP_DIR/lib.sh" ]]; then
    echo "* Error: Failed to download required files from GitHub" >&2
    rm -rf "$TMP_DIR"
    exit 1
fi

echo "* All files downloaded successfully"

# Make scripts executable
chmod +x "$TMP_DIR/panel.sh"
chmod +x "$TMP_DIR/wings.sh"
chmod +x "$TMP_DIR/uninstall.sh"

if [[ "$DO_UNINSTALL" == true ]]; then
  echo "* Starting uninstallation..."
  bash "$TMP_DIR/uninstall.sh"
  echo "* Uninstallation completed"
else
  if [[ "$INSTALL_PANEL" == true ]]; then
    echo "* Starting panel installation..."
    export FQDN="$PANEL_FQDN"
    bash "$TMP_DIR/panel.sh"
  fi

  if [[ "$INSTALL_WINGS" == true ]]; then
    echo "* Starting wings installation..."
    export FQDN="$WINGS_FQDN"
    export EMAIL="$ADMIN_EMAIL"
    export CONFIGURE_FIREWALL=true
    bash "$TMP_DIR/wings.sh"
  fi

  echo "* Installation completed successfully"
  echo "* Admin Username: $USERNAME"
  echo "* Admin Email: $ADMIN_EMAIL"
  echo "* Admin Password: $PANEL_USER_PASSWORD"
  [[ "$INSTALL_PANEL" == true ]] && echo "* Panel FQDN: $PANEL_FQDN"
  [[ "$INSTALL_WINGS" == true ]] && echo "* Wings FQDN: $WINGS_FQDN"
  [[ "$INSTALL_PANEL" == true ]] && echo "* Database Password: $DB_PASSWORD"
fi

echo "* Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "* Setup complete!"
