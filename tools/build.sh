#!/usr/bin/env bash
#
# build.sh - Package an FS22 mod directory into a distributable zip file.
#
# Usage: ./tools/build.sh <mod_directory>
#
# The mod directory must contain a modDesc.xml at its root.
# Output zip is placed in the dist/ directory.

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <mod_directory>"
    echo "Example: $0 examples/FS22_ExampleScript"
    exit 1
fi

MOD_DIR="$1"
MOD_NAME=$(basename "$MOD_DIR")

# Validate mod directory
if [ ! -d "$MOD_DIR" ]; then
    echo "Error: Directory '$MOD_DIR' does not exist."
    exit 1
fi

if [ ! -f "$MOD_DIR/modDesc.xml" ]; then
    echo "Error: No modDesc.xml found in '$MOD_DIR'."
    echo "Every FS22 mod must have modDesc.xml at the root."
    exit 1
fi

# Validate mod name (alphanumeric and underscores only)
if [[ ! "$MOD_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Error: Mod name '$MOD_NAME' contains invalid characters."
    echo "FS22 mod zip names must use only alphanumeric characters and underscores."
    exit 1
fi

# Check for FS22_ prefix convention
if [[ ! "$MOD_NAME" =~ ^FS22_ ]]; then
    echo "Warning: Mod name '$MOD_NAME' does not start with 'FS22_'."
    echo "Convention is to prefix mod names with 'FS22_'."
fi

# Create dist directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DIST_DIR="$(dirname "$SCRIPT_DIR")/dist"
mkdir -p "$DIST_DIR"

ZIP_FILE="$DIST_DIR/${MOD_NAME}.zip"

# Remove old zip if present
if [ -f "$ZIP_FILE" ]; then
    rm "$ZIP_FILE"
fi

# Files/patterns to exclude from the zip
EXCLUDES=(
    "*.blend"
    "*.blend1"
    "*.psd"
    "*.xcf"
    "*.max"
    "*.mb"
    "*.ma"
    ".git/*"
    ".gitignore"
    ".DS_Store"
    "__MACOSX/*"
    "Thumbs.db"
    "*.log"
    "*.bak"
    "*.tmp"
)

# Build exclude args for zip
EXCLUDE_ARGS=()
for pattern in "${EXCLUDES[@]}"; do
    EXCLUDE_ARGS+=(-x "$pattern")
done

# Package the mod - modDesc.xml must be at the zip root
echo "Packaging '$MOD_NAME'..."
cd "$MOD_DIR"
zip -r "$ZIP_FILE" . "${EXCLUDE_ARGS[@]}"
cd - > /dev/null

echo ""
echo "Built: $ZIP_FILE"
echo "Size: $(du -h "$ZIP_FILE" | cut -f1)"
echo ""
echo "Validation checklist:"
echo "  [*] modDesc.xml present at root"

# Quick validation of modDesc.xml
DESC_VERSION=$(grep -oP 'descVersion="\K[^"]+' "$MOD_DIR/modDesc.xml" 2>/dev/null || echo "unknown")
echo "  [$([ "$DESC_VERSION" = "79" ] && echo '*' || echo '!')] descVersion=$DESC_VERSION (expected 79)"

if [ -f "$MOD_DIR/icon.dds" ] || [ -f "$MOD_DIR/icon.png" ]; then
    echo "  [*] Icon file found"
else
    echo "  [!] No icon.dds or icon.png found"
fi

AUTHOR=$(grep -oP '<author>\K[^<]+' "$MOD_DIR/modDesc.xml" 2>/dev/null || echo "")
if [ -n "$AUTHOR" ]; then
    echo "  [*] Author: $AUTHOR"
else
    echo "  [!] No <author> tag found"
fi

echo ""
echo "To test: place $ZIP_FILE (or the unzipped folder) in your FS22 mods directory."
