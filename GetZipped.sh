#!/usr/bin/env bash

# Raycast metadata for integration
# @raycast.schemaVersion 1
# @raycast.title Get Zipped file hashes
# @raycast.mode fullOutput
# @raycast.packageName Get Zipped file hashes
# @raycast.icon 🔓

# Documentation
# @raycast.author Ronan Lynch
# @raycast.descriptionGet Zipped file hashes
# Example: yaaarrrppp


# This script will look for the newest zip folder in downloads folder , unzip it , get the zip's file hash
# and than get the file hashes if multiple files are within 
# and if a single file hash , it will put that hash into clipboard.

# So just copy the zip file name , hit your assaigned hot keys for this script, and a window will pop with
# file names and hashes.



DOWNLOADS_DIR="$HOME/Downloads"
DEST_DIR="$DOWNLOADS_DIR/zipped-files"

# Get the latest ZIP file in Downloads
latest_zip=$(find "$DOWNLOADS_DIR" -maxdepth 1 -type f -name "*.zip" -print0 | xargs -0 ls -t 2>/dev/null | head -n 1)

if [[ -z "$latest_zip" ]]; then
  osascript -e 'display dialog "No ZIP files found in Downloads." buttons {"OK"}'
  exit 1
fi

# Hash the ZIP archive
zip_hash=$(shasum -a 256 "$latest_zip" | awk '{print $1}')

# Clean and recreate unzip directory
rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"

# Unzip
unzip -q "$latest_zip" -d "$DEST_DIR"

# Filter only real files (exclude macOS artifacts)
extracted_files=$(find "$DEST_DIR" -type f ! -path "*/__MACOSX/*" ! -name "._*" ! -name ".DS_Store")

# Count actual extracted files
file_count=$(echo "$extracted_files" | wc -l | tr -d ' ')

# Start result output
result="ZIP Archive: $(basename "$latest_zip")\nZIP Hash: $zip_hash\n\n"

if [[ "$file_count" -eq 1 ]]; then
  file=$(echo "$extracted_files")
  file_name=$(basename "$file")
  file_hash=$(shasum -a 256 "$file" | awk '{print $1}')
  result+="Extracted file: $file_name\nSHA256: $file_hash"
  echo "$file_hash" | pbcopy
else
  result+="Extracted files:\n"
  while IFS= read -r file; do
    file_name=$(basename "$file")
    file_hash=$(shasum -a 256 "$file" | awk '{print $1}')
    result+="$file_name: $file_hash\n"
  done <<< "$extracted_files"
fi

# Display the result
osascript <<EOF
display dialog "$(echo -e "$result" | sed 's/"/\\"/g')" with title "File Hashes" default answer "$(echo -e "$result" | sed 's/"/\\"/g')"
EOF

