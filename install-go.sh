#!/bin/bash
# Install Go and TinyGo script for Debian/Ubuntu systems

# Configuration - update these versions as needed
GO_VERSION="1.25.5"
TINYGO_VERSION="0.41.1"

set -e

echo "Updating package lists..."
apt-get update -qq

echo "Installing Go $GO_VERSION..."
# Remove existing Go installation
rm -rf /usr/local/go
# Download and install Go
wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

GO_BIN_PATH="/usr/local/go/bin"

# Function to add PATH idempotently to a file
add_to_path_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        touch "$file"
    fi
    if ! grep -q "$GO_BIN_PATH" "$file" 2>/dev/null; then
        {
            echo ""
            echo "# Added by Go installer"
            echo "if [ -d \"$GO_BIN_PATH\" ] ; then"
            echo "    PATH=\"\$PATH:$GO_BIN_PATH\""
            echo "fi"
        } >> "$file"
        echo "Added Go PATH to $file"
    else
        echo "Go PATH already in $file"
    fi
}

# Add to .bashrc (non-login interactive shells)
add_to_path_file "$HOME/.bashrc"

# Add to .profile (login shells)
add_to_path_file "$HOME/.profile"

# Apply PATH for the current session
export PATH="$PATH:$GO_BIN_PATH"

echo "Installing TinyGo $TINYGO_VERSION..."
# Download and install TinyGo
wget -q "https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo_${TINYGO_VERSION}_amd64.deb"
apt-get install -y "./tinygo_${TINYGO_VERSION}_amd64.deb"
rm "tinygo_${TINYGO_VERSION}_amd64.deb"

echo "Installation complete. Log out and back in for full PATH persistence."
echo "Verify installations:"
go version
tinygo version