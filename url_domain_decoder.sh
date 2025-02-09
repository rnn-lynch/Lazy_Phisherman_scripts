#!/usr/bin/env bash

# Raycast metadata for integration
# @raycast.schemaVersion 1
# @raycast.title Decode Proofpoint/SafeLink/URL Encoded URLs
# @raycast.mode fullOutput
# @raycast.packageName URL Decoder
# @raycast.icon 🔓

# Documentation
# @raycast.author Rónán Lynch (ZeroCraic)
# @raycast.description Decodes Proofpoint, SafeLink, and URL Encode links directly from the clipboard and allows the decoded link to be pasted from clipboard.

# Set up in raycast as hotkey, copy safelink/proofpoint link, press your assaigned hotkeys, 
# the decoded link will be printed and also added to your clipboard for pasting.

# Fetch the URL from the clipboard
encoded_url=$(pbpaste)

# Check if the clipboard contains any text
if [ -z "$encoded_url" ]; then
  echo "No URL found in clipboard. Please copy a URL and try again."
  exit 1
fi

# Function to decode URL-encoded strings
url_decode() {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}

# Function to decode standard Proofpoint URLs
decode_proofpoint() {
  if [[ "$encoded_url" == *"urldefense.proofpoint.com"* ]]; then
    local u_param=$(echo "$encoded_url" | awk -F'[?&]' '{for(i=1;i<=NF;i++) if($i ~ /^u=/) print substr($i,3)}')
    if [ -n "$u_param" ]; then
      local modified_url="${u_param//-/%}"
      modified_url="${modified_url//_//}"
      local decoded_url=$(url_decode "$modified_url")
      echo "Decoded Proofpoint URL:"
      echo "$decoded_url"
      echo "$decoded_url" | pbcopy
      exit 0
    else
      echo "Error: Unable to extract 'u' parameter from Proofpoint URL."
      exit 1
    fi
  fi
}

# Function to decode SafeLink URLs
decode_safelink() {
  if [[ "$encoded_url" == *"safelinks.protection.outlook.com"* ]]; then
    local url_param=$(echo "$encoded_url" | awk -F'[?&]' '{for(i=1;i<=NF;i++) if($i ~ /^url=/) print substr($i,5)}')
    if [ -n "$url_param" ]; then
      local decoded_url=$(url_decode "$url_param")
      echo "Decoded SafeLink URL:"
      echo "$decoded_url"
      echo "$decoded_url" | pbcopy

      exit 0
    else
      echo "Error: Unable to extract 'url' parameter from SafeLink URL."
      exit 1
    fi
  fi
}

# Function to decode URLEncode (urldefense.com) links for both v2 and v3
decode_urldefense() {
  if [[ "$encoded_url" == *"urldefense.com"* ]]; then
    # Using awk to extract URL based on v3 pattern with double underscores __https://...__;
    local embedded_url=$(echo "$encoded_url" | awk -F'__' '{print $2}')
    # If no embedded URL found, fall back to v2 pattern
    if [ -z "$embedded_url" ]; then
      embedded_url=$(echo "$encoded_url" | awk -F'[?&]' '{for(i=1;i<=NF;i++) if($i ~ /^url=/) print substr($i,5)}')
    fi
    if [ -n "$embedded_url" ]; then
      # URL-decode the extracted embedded URL
      local decoded_url=$(url_decode "$embedded_url")
      echo "Decoded URLEncode URL:"
      echo "$decoded_url"
      echo "$decoded_url" | pbcopy
      exit 0
    else
      echo "Error: Unable to extract embedded URL from urldefense.com link."
      exit 1
    fi
  fi
}

# Attempt to decode as Proofpoint URL
decode_proofpoint

# Attempt to decode as SafeLink URL
decode_safelink

# Attempt to decode as URLEncode (urldefense.com) URL
decode_urldefense

# If not Proofpoint, SafeLink, or URLEncode, attempt general URL decoding
decoded_url=$(url_decode "$encoded_url")
echo "Decoded URL:"
echo "$decoded_url"
