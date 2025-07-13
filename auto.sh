#!/bin/bash

set -e

echo "[*] Starting full Lilac + Chromebrew install..."

# Ensure running as chronos
if [ "$USER" != "chronos" ]; then
    echo "[!] Please run this script as user 'chronos', not root."
    exit 1
fi

# Check for curl, unzip, tar, gzip, bash
for cmd in curl unzip tar gzip bash; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[!] Missing command: $cmd"
        echo "You must install this manually first (via dev_install or preinstalled ChromeOS tools)."
        exit 1
    fi
done

# --- Install Chromebrew if not present ---
if [ ! -f /usr/local/bin/crew ]; then
    echo "[*] Installing Chromebrew..."
    sudo rm -rf /usr/local/*
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/skycocker/chromebrew/master/install.sh)"
else
    echo "[*] Chromebrew already installed."
fi

# Add Chromebrew to PATH if not already
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
    export PATH="/usr/local/bin:$PATH"
fi

# --- Install dependencies via crew ---
echo "[*] Installing required packages via crew..."
crew install gcc make g++ git

# --- Clone Lilac ---
cd ~
if [ -d lilac ]; then
    echo "[*] Removing existing lilac folder..."
    rm -rf lilac
fi

echo "[*] Cloning Lilac repo..."
git clone https://github.com/MercuryWorkshop/lilac.git
cd lilac

# --- Build Lilac ---
echo "[*] Building Lilac..."
make -j$(nproc)

# --- Install Lilac ---
echo "[*] Installing Lilac to ~/.local/bin..."
mkdir -p ~/.local/bin
cp lilac ~/.local/bin/

# --- Add to PATH ---
if ! grep -q '.local/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/.local/bin:$PATH"

# --- Done ---
if command -v lilac &>/dev/null; then
    echo "[✔] Lilac installed successfully!"
    lilac --help
else
    echo "[✘] Lilac binary not detected in PATH."
    exit 1
fi
