#!/usr/bin/env bash
set -euo pipefail

# cd into script dir
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$SCRIPT_DIR"

# get repository root directory on local system
REPO_ROOT="$(git rev-parse --show-superproject-working-tree)"

# define working directory
WORK_DIR="$REPO_ROOT"/tools/content_tools/MaterialIcons

# make directory for Material Icons font building
echo "Create working directory: $WORK_DIR"
mkdir -p "$WORK_DIR"

# download font and codepoints
MA_CODEPOINTS_FILE="https://github.com/google/material-design-icons/raw/refs/heads/master/font/MaterialIcons-Regular.codepoints"
echo "Downloading: $MA_CODEPOINTS_FILE ..."
curl -sLo "$WORK_DIR/MaterialIcons-Regular.codepoints" "$MA_CODEPOINTS_FILE"

MA_TTF_FILE="https://github.com/google/material-design-icons/raw/refs/heads/master/font/MaterialIcons-Regular.ttf"
echo "Downloading: $MA_TTF_FILE ..."
curl -sLo "$WORK_DIR/MaterialIcons-Regular.ttf" "$MA_TTF_FILE"

# extract all character codes from codepoints
echo "Extracting all character codes from codepoints file..."
awk '{ print "0x" toupper($2) }' "$WORK_DIR/MaterialIcons-Regular.codepoints" > "$WORK_DIR/charset.txt"

# generate msdf
echo "Generating MSDF..."
cd "$REPO_ROOT"/src
go run generators/msdf/main.go MaterialIcons

# copy output
echo "Copying output files..."
cp -v "$WORK_DIR/out/MaterialIcons-Regular.bin" "$REPO_ROOT/src/editor/editor_embedded_content/editor_content/fonts/MaterialIcons-Regular.bin"
cp -v "$WORK_DIR/out/MaterialIcons-Regular.png" "$REPO_ROOT/src/editor/editor_embedded_content/editor_content/fonts/MaterialIcons-Regular.png"
cp -v "$WORK_DIR/charset.txt" "$REPO_ROOT/src/editor/editor_embedded_content/editor_content/fonts/MaterialIcons-Regular.charset.txt"

# clean up
echo "Cleaning up..."
rm -vr "$WORK_DIR"