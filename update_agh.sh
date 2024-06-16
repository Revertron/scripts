#!/opt/bin/bash

# AdGuardHome update script for routers using opkg, like Keenetic.
# Developed by Revertron. Home URL: https://github.com/Revertron/scripts

# Variables
BINARY_PATH="/opt/bin/AdGuardHome"
INIT_SCRIPT="/opt/etc/init.d/S99adguardhome"
REPO_URL="https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest"
DOWNLOAD_DIR="/tmp/adguardhome_update"
ARCHIVE_NAME="adguardhome.tar.gz"
PLATFORM="mipsle"
OS="linux"

# Create download directory
mkdir -p $DOWNLOAD_DIR
cd $DOWNLOAD_DIR

# Get current version
CURRENT_VERSION=$($BINARY_PATH --version | awk '{print $NF}')
echo "Current version: $CURRENT_VERSION"

# Get latest version from GitHub
LATEST_VERSION=$(wget -qO- $REPO_URL | jq -r '.tag_name')
echo "Latest version: $LATEST_VERSION"

# Check if update is needed
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Updating to version $LATEST_VERSION..."

    # Get download URL for the latest version
    DOWNLOAD_URL=$(wget -qO- $REPO_URL | jq -r '.assets[] | select(.name | contains("'$PLATFORM'") and contains("'$OS'")) | .browser_download_url')

    # Download the latest version archive
    wget -qO $ARCHIVE_NAME $DOWNLOAD_URL
    if [ $? -ne 0 ]; then
        echo "Failed to download the archive"
        exit 1
    fi

    # Extract only the binary
    tar -xzf $ARCHIVE_NAME --strip-components=1 -C $DOWNLOAD_DIR AdGuardHome

    $INIT_SCRIPT stop

    # Move the binary to the target directory
    mv -f $DOWNLOAD_DIR/AdGuardHome $BINARY_PATH
    if [ $? -eq 0 ]; then
        echo "Update successful!"
    else
        echo "Failed to update the binary"
        exit 1
    fi

    $INIT_SCRIPT start

    # Cleanup
    rm -f $ARCHIVE_NAME
else
    echo "Already up-to-date!"
fi

# Remove download directory
rm -rf $DOWNLOAD_DIR
