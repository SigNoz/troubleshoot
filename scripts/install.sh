#!/bin/bash

OWNER=signoz
REPOSITORY=troubleshoot
BINARY_NAME=troubleshoot

# Log error
log_error() {
    echo -e "\n+++++++++++ ERROR ++++++++++++++++++++++"
    echo -e "$1"
    echo -e "++++++++++++++++++++++++++++++++++++++++\n"
}

# Log info
log_info() {
    echo -e "\n+++++++++++ INFO ++++++++++++++++++++++"
    echo -e "$1"
    echo -e "++++++++++++++++++++++++++++++++++++++++\n"
}

# During non-zero exit Prints a friendly good bye message and exits the script.
bye() {
    if [ "$?" -ne 0 ]; then
        log_error "Something went wrong while fetching ${BINARY_NAME} binary.\nYou can download the appropriate release of ${BINARY_NAME} from this link: https://github.com/${OWNER}/${REPOSITORY}/releases"
    fi
    exit 1
}

# Check whether the given command exists.
has_cmd() {
    command -v "$1" > /dev/null 2>&1
}

# Check whether 'wget' command exists.
has_wget() {
    has_cmd wget
}

# Check whether 'curl' command exists.
has_curl() {
    has_cmd curl
}

# Set kernel variable based on the OS kernel
set_kernel() {
    uname_kernel="$(uname -s)"
    KERNEL=$(echo "${uname_kernel,,}")
}

# Set chip variable based on machine hardware
set_chip() {
    uname_hardware="$(uname -m)"
    CHIP=$(echo "${uname_hardware,,}")
}

# Set asset name and URL
set_asset() {
    ASSET_NAME="${BINARY_NAME}-${LATEST_VERSION}-linux-amd64.tar.gz"
    ASSET_URL="https://github.com/${OWNER}/${REPOSITORY}/releases/download/${LATEST_VERSION}/${ASSET_NAME}"
}

# Download file from the URL passed
download_file() {
    if has_curl; then
        curl -sfOL "$1"
    elif has_wget; then
        wget -qN "$1"
    fi
    if [ $? -ne 0 ]; then
        log_error "Error while downloading asset.\nMake sure there are assets attached in the release of the remote repository."
        exit 1
    fi
}

# Fetch troubleshoot binary
fetch_troubleshoot() {
    log_info "Downloading $ASSET_NAME from URL the below:\n$ASSET_URL"
    download_file "$ASSET_URL"
    log_info "Asset downloaded successfully.\nExtracting ${BINARY_NAME} binary from $ASSET_NAME"
    tar xzf $ASSET_NAME
    rm $ASSET_NAME

    log_info "$BINARY_NAME binary successfully downloaded.\n\nUsage: \n\n\t./$BINARY_NAME checkEndpoint --endpoint=localhost:4317\n"
}

# Verify md5 checksum
check_md5() {
    download_file "${ASSET_URL}.md5"
    echo -n "$(cat ${ASSET_NAME}.md5) $ASSET_NAME" > "${ASSET_NAME}.md5"
    md5sum -c "${ASSET_NAME}.md5"
}

# Run bye if any interrupt or failure happens
trap bye 1 2 3 6

LATEST_VERSION="$(git describe --abbrev=0 --tags 2> /dev/null)"
if [ $? -ne 0 ]; then
    log_error "Error while fetching latest version tag.\nMake sure there are tags. For example: v0.0.1"
    exit 0
fi

set_kernel
set_chip
set_asset

fetch_troubleshoot
