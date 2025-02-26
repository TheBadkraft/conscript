#!/bin/bash

# Install script for sigma_test library
# Run this script from the ./tools/sigtest/ directory

# Source and destination paths
LIB_SOURCE="./libsigtest.so"
LIB_DEST="/usr/lib/libsigtest.so"

HEADER_SOURCE="./sigtest.h"
HEADER_DEST="/usr/include/sigtest.h"

# Check if the script is being run from the correct directory
if [ ! -f "$LIB_SOURCE" ] || [ ! -f "$HEADER_SOURCE" ]; then
    echo "Error: This script must be run from the ./tools/sigtest/ directory."
    exit 1
fi

# Check for root permissions
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script requires root permissions to install files to /usr/lib and /usr/include."
    echo "Please run with sudo: sudo ./install.sh"
    exit 1
fi

# Copy the shared library to /usr/lib
echo "Installing libsigtest.so to /usr/lib..."
cp "$LIB_SOURCE" "$LIB_DEST"
if [ $? -eq 0 ]; then
    echo "libsigtest.so installed successfully."
else
    echo "Error: Failed to install libsigtest.so."
    exit 1
fi

# Copy the header file to /usr/include
echo "Installing sigtest.h to /usr/include..."
cp "$HEADER_SOURCE" "$HEADER_DEST"
if [ $? -eq 0 ]; then
    echo "sigtest.h installed successfully."
else
    echo "Error: Failed to install sigtest.h."
    exit 1
fi

echo "Installation complete!"
