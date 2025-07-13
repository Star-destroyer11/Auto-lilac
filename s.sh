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

# Check if /usr/local is writable
if [ ! -w /usr/local ]; then
    echo "[*] /usr/local is not writable. Attempting to remount read-write..."
    sudo mount -o remount,rw /usr/local || {
        echo "[!] Failed to remount /usr/local. You may need to enable Linux (Crostini) or choose another install method."
        exit 1
    }
else
    echo "[*] /usr/local is writable."
fi

# Remove old Chromebrew install if it exists
if [ -d /usr/local ]; then
    echo "[*] Cleaning /usr/local directory for fresh install..."
    sudo rm -rf /usr/local/*
fi

# Run Chromebrew install script
echo "[*] Running Chromebrew install script..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/skycocker/chromebrew/master/install.sh)"

# Add Chromebrew to PATH
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
