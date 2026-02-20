#!/usr/bin/env bash
set -eu
set -o pipefail

# Get formatted list for fzf
selected=$(rbw ls --fields name,user,folder | \
  awk -F'\t' '{
        display = $1
        if ($3 != "" && $3 != "null") {
            display = $3 "/" $1
        }
        printf "%s\t%s\t%s\t%s\n", display, $1, $2, $3
    }' | \
    sort | \
  fzf --with-nth=1 -d '\t' --height=40% --reverse)

[ -z "$selected" ] && exit 0

# Parse selection
IFS=$'\t' read -r display entry_name username folder <<< "$selected"

# Get data in JSON format
if [ -n "$folder" ] && [ "$folder" != "null" ] && [ "$folder" != "(null)" ]; then
  json_data=$(rbw get "$entry_name" --folder="$folder" --raw)
else
  json_data=$(rbw get "$entry_name" --raw)
fi

# Extract data
name_val=$(echo "$json_data" | jq -r '.name')
uri_val=$(echo "$json_data" | jq -r '.data.uris[0].uri // empty')
user_val=$(echo "$json_data" | jq -r '.data.username // empty')
pass_val=$(echo "$json_data" | jq -r '.data.password // empty')
totp_val=$(echo "$json_data" | jq -r '.data.totp // empty')

# Display result
echo "name: $name_val"
if [ -n "$uri_val" ]; then
  echo "link: $uri_val"
else
  echo "link: (no link)"
fi
echo ""
echo "username: $user_val"
echo "password: $pass_val"

# If TOTP exists, show it
if [ -n "$totp_val" ]; then
  echo ""
  echo "TOTP code:"
  # Get current TOTP code
  if [ -n "$folder" ] && [ "$folder" != "null" ] && [ "$folder" != "(null)" ]; then
    rbw totp "$entry_name" --folder="$folder"
  else
    rbw totp "$entry_name"
  fi
fi
