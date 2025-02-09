#!/usr/bin/env bash



# Raycast parameters for this script
# @raycast.schemaVersion 1
# @raycast.title Decode & Process URL/Base64 with Email Handling
# @raycast.mode fullOutput
# @raycast.packageName | Decoder
# @raycast.icon 🛠

# Documentation
# @raycast.author Rónán Lynch (ZeroCraic)
# @raycast.description Decodes URL/Base64, finds and replaces emails (both Base64-encoded and clear-text), extracts domains, and appends the dummy email if an email is found after the hash (#) or 'E='.

# Capture clipboard input
input=$(pbpaste)

# List of possible first names
names=("mine" "friend" "John" "Jim" "Mary" "money" "test" "frank" "Anne" "Matthew" "Anthony" "Donald" "Mark" "Paul" "Steven" "Andrew" "Kenneth" "Joshua" "George" "Kevin" "Brian" "Edward" "Ronald" "Timothy" "Jason" "Jeffrey" "Ryan" "Jacob" "Gary" "Nicholas" "Eric" "Stephen" "Jonathan" "Larry" "Justin" "Scott" "Brandon" "Benjamin" "Samuel" "Frank" "Gregory" "Raymond" "Alexander" "Patrick" "Jack" "Dennis" "Jerry" "Tyler" "Aaron" "Franklin" "Charles" "Richard" "David" "Gregory" "Harold" "Nick" "Nathan" "Bradley" "Arthur")

# Randomly select a name from the list
random_name=${names[$RANDOM % ${#names[@]}]}

# Construct the randomized dummy email
dummy_email="$random_name@microsoft.com"
dummy_email_base64=$(echo -n "$dummy_email" | base64)

# Functions
decode_base64() {
    echo "$1" | base64 --decode 2>/dev/null || echo "$1"
}

decode_url() {
    echo -e "$(printf '%b' "${1//%/\\x}")"
}

# Main processing
echo -e "${YELLOW}Original String:${ENDCOLOR} $input\n"

# Step 1: Split input at the hash (#) symbol or 'E='
if [[ "$input" == *#* ]]; then
    # Split at '#'
    base64_part="${input%%#*}"
    extra_part="${input#*#}"
    separator='#'
elif [[ "$input" == *E=* ]]; then
    # Split at 'E='
    base64_part="${input%%E=*}"
    extra_part="${input#*E=}"
    separator='E='
else
    # No separator found
    base64_part="$input"
    extra_part=""
    separator=''
fi

# Decode the main Base64 part of the URL
decoded_base64=$(decode_base64 "$base64_part")

# Step 2: Detect and replace email in the extra part (after separator)
if [[ "$extra_part" =~ [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
    # If a clear-text email is detected, replace it with the dummy email in clear text
    combined_decoded="$base64_part$separator$dummy_email"
elif [[ "$extra_part" =~ ^[a-zA-Z0-9+/=]+$ ]]; then
    # If a Base64-encoded email is detected, replace it with the dummy email in Base64
    decoded_extra_part=$(decode_base64 "$extra_part")
    if [[ "$decoded_extra_part" =~ [a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,} ]]; then
        combined_decoded="$base64_part$separator$dummy_email_base64"
    else
        # If no email is detected in decoded form, leave it as-is
        combined_decoded="$base64_part$separator$extra_part"
    fi
else
    # If no email is found, keep the extra part as-is
    combined_decoded="$base64_part$separator$extra_part"
fi

echo -e "${YELLOW}Combined Decoded String with Dummy Email:${ENDCOLOR} $combined_decoded\n"

# Step 3: URL decode the combined decoded string
decoded_url=$(decode_url "$combined_decoded")
echo -e "${YELLOW}URL Decoded String:${ENDCOLOR} $decoded_url\n"

# Step 4: Extract domains and replace any emails with the dummy email in the final processed text
domains=$(echo "$decoded_url" | grep -oE '\b([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}\b' | sort -u)
processed_text=$(echo "$decoded_url" | sed -E "s/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/$dummy_email/g")

# Display results
echo -e "${YELLOW}Domains Found:${ENDCOLOR}"
echo "$domains"
echo -e "\n${YELLOW}Processed Text (Emails Replaced):${ENDCOLOR}\n$processed_text"