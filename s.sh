#!/bin/bash

# Chromebrew Installer (Clean Install)
# Tested on ChromeOS v2 shell (Dev Mode, chronos user)

# Exit on any error
set -e

echo "[*] Starting clean Chromebrew install..."

# Step 1: Must be 'chronos'
if [ "$USER" != "chronos" ]; then
    echo "[!] Please run this script as user 'chronos', not root."
    exit 1
fi

# Step 2: Check dependencies
for cmd in curl tar gzip bash; do
    if ! command -v $cmd &> /dev/null; then
        echo "[!] Missing dependency: $cmd"
        exit 1
    fi
done

# Step 3: Clean any old Chromebrew install
echo "[*] Cleaning old Chromebrew install (if any)..."
sudo rm -rf /usr/local

# Step 4: Run Chromebrew installer
echo "[*] Downloading and running Chromebrew install script..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/skycocker/chromebrew/master/install.sh)"

# Step 5: Add Chromebrew to PATH
echo "[*] Updating PATH..."
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Step 6: Confirm success
if command -v crew &> /dev/null; then
    echo "[✔] Chromebrew installed successfully!"
    echo "You can now run: crew install protobuf"
else
    echo "[✘] Install failed. Please check output for errors."
    exit 1
fi
