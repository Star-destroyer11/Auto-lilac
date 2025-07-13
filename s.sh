#!/bin/bash

set -e

echo "[*] Starting Chromebrew install script..."

# Ensure running as 'chronos'
if [ "$USER" != "chronos" ]; then
    echo "[!] Please run this script as user 'chronos', not root."
    exit 1
fi

# Check required commands
for cmd in curl tar gzip bash; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[!] Missing dependency: $cmd"
        exit 1
    fi
done

# /usr/local is read-only, so delete contents if any
if [ -d /usr/local ]; then
    echo "[*] Cleaning contents of /usr/local ..."
    sudo rm -rf /usr/local/* /usr/local/.??* 2>/dev/null || echo "[!] Some files could not be deleted, continuing..."
else
    echo "[*] /usr/local does not exist, proceeding..."
fi

# Run Chromebrew install script
echo "[*] Running Chromebrew install script..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/skycocker/chromebrew/master/install.sh)"

# Add Chromebrew to PATH if not already added
if ! grep -q '/usr/local/bin' ~/.bashrc; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
fi
source ~/.bashrc

# Confirm installation
if command -v crew >/dev/null 2>&1; then
    echo "[✔] Chromebrew installed successfully!"
    echo "Run 'crew install protobuf' to install protobuf."
else
    echo "[✘] Chromebrew install failed or crew not found in PATH."
    exit 1
fi
