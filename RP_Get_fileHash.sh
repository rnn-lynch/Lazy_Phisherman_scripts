#!/bin/bash
# Raycast metadata for integration
# @raycast.schemaVersion 1
# @raycast.title RubberPhish Get filehash
# @raycast.mode fullOutput
# @raycast.packageName RubberPhish Get filehash
# @raycast.icon 🔓

# Documentation
# @raycast.author Rónán Lynch (ZeroCraic)
# @raycast.description RubberPhish Get filehash
# Example: RubberPhish to the rescue!

# When you copy the file name and than press the hotkeys to run this script, 
# the script will find it in downloads folder and #convert the file to its hash 
# and add to clipboard, which you can paste.

# Get filename from clipboard
filename=$(pbpaste)  # For macOS (use xclip or xsel on Linux)

# Define the Downloads directory
downloads_dir=~/Downloads

# Full file path
file_path="$downloads_dir/$filename"

# Check if the file exists
if [[ ! -f "$file_path" ]]; then
    echo "Error: File '$filename' not found in $downloads_dir."
    exit 1
fi

# Get SHA256 hash of the file
file_hash=$(sha256sum "$file_path" | awk '{print $1}')

# Make file_hash globally available
export FILE_HASH="$file_hash"

# Output results
osascript -e "set the clipboard to \"$file_hash\""
echo "$filename"
echo "$file_hash"

