#!/usr/bin/env bash

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: fetchext --extensions <extensions.json> [--mapping <mapping.json>]"
    echo ""
    echo "extensions.json format:"
    echo '  [{"slug": "ublock-origin"}, {"slug": "bitwarden-password-manager"}]'
    echo ""
    echo "mapping.json format (optional):"
    echo '  {"ublock-origin": "cjpalhdlnbpafiamejdnhcphjbkeiagm", "bitwarden-password-manager": "nngceckbapebfimnlniiiahkandclblb"}'
    exit 1
fi

UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

EXTENSIONS_FILE=""
MAPPING_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --extensions)
            EXTENSIONS_FILE="$2"
            shift 2
            ;;
        --mapping)
            MAPPING_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check required files
if [ -z "$EXTENSIONS_FILE" ]; then
    echo "Error: --extensions is required"
    exit 1
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Error: File '$EXTENSIONS_FILE' not found"
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required for parsing JSON files"
    echo "Install it with: sudo apt-get install jq  or  brew install jq"
    exit 1
fi

# Load mapping if provided
declare -A SLUG_TO_ID
if [ -n "$MAPPING_FILE" ] && [ -f "$MAPPING_FILE" ]; then
    echo "  # Loading mapping from $MAPPING_FILE" >&2
    while IFS= read -r slug; do
        id=$(jq -r ".\"$slug\"" "$MAPPING_FILE")
        if [ "$id" != "null" ] && [ -n "$id" ]; then
            SLUG_TO_ID["$slug"]="$id"
        fi
    done < <(jq -r 'keys[]' "$MAPPING_FILE")
fi

# Function to compute SHA256 in base64 (SRI format)
compute_hash() {
    local file=$1
    
    # Try different methods to compute SHA256 in base64
    if command -v openssl &> /dev/null; then
        # Using openssl (most reliable)
        sha256_base64=$(openssl dgst -sha256 -binary "$file" | base64 | tr -d '\n')
        echo "sha256-$sha256_base64"
    elif command -v sha256sum &> /dev/null; then
        # Using sha256sum (Linux)
        sha256_hex=$(sha256sum "$file" | cut -d' ' -f1)
        sha256_base64=$(echo -n "$sha256_hex" | xxd -r -p | base64 | tr -d '\n')
        echo "sha256-$sha256_base64"
    elif command -v shasum &> /dev/null; then
        # Using shasum (macOS)
        sha256_hex=$(shasum -a 256 "$file" | cut -d' ' -f1)
        sha256_base64=$(echo -n "$sha256_hex" | xxd -r -p | base64 | tr -d '\n')
        echo "sha256-$sha256_base64"
    elif command -v nix-hash &> /dev/null; then
        # Using nix-hash as fallback
        hash32=$(nix-hash --type sha256 --flat --base32 "$file")
        # Convert base32 to base64 using python or perl
        if command -v python3 &> /dev/null; then
            sha256_base64=$(python3 -c "import base64; import sys; print(base64.b64encode(base64.b32decode('$hash32'.upper())).decode(), end='')")
            echo "sha256-$sha256_base64"
        elif command -v perl &> /dev/null; then
            sha256_base64=$(perl -MMIME::Base64 -e "print encode_base64(decode_base32('$hash32'), '')")
            echo "sha256-$sha256_base64"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# Function to fetch extension by ID
fetch_extension() {
    local id=$1
    local slug=$2
    
    url="https://clients2.google.com/service/update2/crx?response=redirect&os=linux&arch=x64&os_arch=x86_64&nacl_arch=x86-64&prod=chromiumcrx&prodchannel=stable&prodversion=120.0.0.0&acceptformat=crx3&x=id%3D${id}%26installsource%3Dondemand%26uc"

    tmpfile=$(mktemp)

    echo "  # Fetching $slug ($id)..." >&2
    
    if curl -fSL -A "$UA" --max-time 30 "$url" -o "$tmpfile" 2>/dev/null; then
        if [ -f "$tmpfile" ]; then
            size=$(stat -c%s "$tmpfile" 2>/dev/null || stat -f%z "$tmpfile" 2>/dev/null)
            
            if [ "$size" -gt 1000 ]; then
                # Compute hash
                hash=$(compute_hash "$tmpfile")
                
                if [ -n "$hash" ]; then
                    echo "  $slug = {"
                    echo "    id = \"$id\";"
                    echo "    hash = \"$hash\";"
                    echo "  };"
                    echo "  # OK: $slug fetched successfully" >&2
                else
                    echo "  # WARNING: Could not compute hash for $slug" >&2
                    echo "  $slug = {"
                    echo "    id = \"$id\";"
                    echo "    hash = \"\";"
                    echo "  };"
                fi
            else
                echo "  # FAILED: $slug returned invalid file (size: $size bytes)" >&2
                echo "  $slug = {"
                echo "    id = \"$id\";"
                echo "    hash = \"\";"
                echo "  };"
            fi
        else
            echo "  # FAILED: No file downloaded for $slug" >&2
            echo "  $slug = {"
            echo "    id = \"$id\";"
            echo "    hash = \"\";"
            echo "  };"
        fi
    else
        echo "  # FAILED: Could not fetch $slug (ID: $id)" >&2
        echo "  $slug = {"
        echo "    id = \"$id\";"
        echo "    hash = \"\";"
        echo "  };"
    fi

    rm -f "$tmpfile"
}

# Main execution
echo "{"

# Read extensions from JSON array
length=$(jq length "$EXTENSIONS_FILE")
for i in $(seq 0 $((length - 1))); do
    slug=$(jq -r ".[$i].slug" "$EXTENSIONS_FILE")
    
    if [ "$slug" = "null" ] || [ -z "$slug" ]; then
        echo "  # WARNING: Missing 'slug' at index $i" >&2
        continue
    fi
    
    # Try to get ID from mapping or from direct field in JSON
    id=$(jq -r ".[$i].id // empty" "$EXTENSIONS_FILE")
    
    if [ -z "$id" ] || [ "$id" = "null" ]; then
        # Look up in mapping
        id="${SLUG_TO_ID[$slug]}"
    fi
    
    if [ -z "$id" ]; then
        echo "  # ERROR: No ID found for slug: $slug" >&2
        echo "  $slug = {"
        echo "    id = \"\";"
        echo "    hash = \"\";"
        echo "  };"
    else
        fetch_extension "$id" "$slug"
        sleep 0.5
    fi
done

echo "}"
