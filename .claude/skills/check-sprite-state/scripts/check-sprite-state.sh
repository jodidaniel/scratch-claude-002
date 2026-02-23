#!/bin/bash
# Check Sprite State Script
# Usage: ./check-sprite-state.sh [sprite-name]
# Requires either: (1) sprites CLI with auth, or (2) SPRITES_API_TOKEN env var

set -e

SPRITE_NAME="${1:-}"
API_TOKEN="${SPRITES_API_TOKEN:-}"
PATH="$PATH:$HOME/.local/bin"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
  echo -e "${BLUE}=== Sprite State Check ===${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

check_cli_auth() {
  if ! command -v sprite &>/dev/null; then
    print_error "sprites CLI not found in PATH"
    echo "Install it with: curl -fsSL https://sprites.dev/install.sh | sh"
    return 1
  fi

  # Quick check if authenticated
  if sprite list &>/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

get_sprite_via_cli() {
  local name=$1

  if ! check_cli_auth; then
    print_error "Sprites CLI not authenticated"
    return 1
  fi

  # List sprites and filter by name
  if sprite list 2>/dev/null | grep -q "^$name"; then
    print_success "Sprite '$name' found via CLI"

    # Try to get more info via API if token is available
    if [ -n "$API_TOKEN" ]; then
      get_sprite_via_api "$name"
    fi
    return 0
  else
    print_error "Sprite '$name' not found"
    return 1
  fi
}

get_sprite_via_api() {
  local name=$1

  if [ -z "$API_TOKEN" ]; then
    return 1
  fi

  print_header
  echo "Querying sprite: $name"
  echo ""

  RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer $API_TOKEN" \
    "https://api.sprites.dev/v1/sprites/$name")

  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
  BODY=$(echo "$RESPONSE" | sed '$d')

  if [ "$HTTP_CODE" -eq 401 ]; then
    print_error "Authentication failed (401)"
    echo "Verify your SPRITES_API_TOKEN is valid"
    return 1
  elif [ "$HTTP_CODE" -eq 404 ]; then
    print_error "Sprite not found (404)"
    return 1
  elif [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    print_success "Retrieved sprite information"
    echo ""
    echo "Sprite Details:"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
    return 0
  else
    print_error "API error (HTTP $HTTP_CODE)"
    return 1
  fi
}

list_all_sprites() {
  print_header
  echo "Listing all sprites..."
  echo ""

  if [ -n "$API_TOKEN" ]; then
    RESPONSE=$(curl -s -w "\n%{http_code}" \
      -H "Authorization: Bearer $API_TOKEN" \
      "https://api.sprites.dev/v1/sprites?limit=100")

    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
      echo "$BODY" | jq '.sprites[] | {name, status, url, updated_at}' 2>/dev/null || echo "$BODY"
      return 0
    else
      print_error "Failed to list sprites (HTTP $HTTP_CODE)"
      return 1
    fi
  elif check_cli_auth; then
    sprite list
    return 0
  else
    print_error "No authentication method available"
    return 1
  fi
}

check_http_health() {
  local url=$1

  if [ -z "$url" ]; then
    return 1
  fi

  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null || echo "000")

  if [ "$HTTP_STATUS" -eq 200 ]; then
    print_success "HTTP health check passed ($HTTP_STATUS)"
    return 0
  elif [ "$HTTP_STATUS" -eq 000 ]; then
    print_error "Connection timeout or failed"
    return 1
  else
    print_warning "HTTP health check returned $HTTP_STATUS"
    return 1
  fi
}

# Main logic
if [ -z "$SPRITE_NAME" ]; then
  print_header
  echo "No sprite name provided"
  echo ""
  echo "Usage: $0 <sprite-name>"
  echo "   or: $0                    (lists all sprites)"
  echo ""
  echo "Examples:"
  echo "  $0 my-sprite"
  echo "  $0                         # List all sprites"
  echo ""
  echo "Environment variables:"
  echo "  SPRITES_API_TOKEN          API token for direct API access"
  echo ""

  # List all sprites if either auth method is available
  if list_all_sprites; then
    exit 0
  else
    print_error "Please provide a sprite name or authenticate with the sprites CLI"
    exit 1
  fi
fi

print_header
echo "Checking sprite: $SPRITE_NAME"
echo ""

# Try API first if token is available
if [ -n "$API_TOKEN" ]; then
  if get_sprite_via_api "$SPRITE_NAME"; then
    echo ""
    # Also do HTTP health check if we got the sprite info
    URL=$(echo "$BODY" | jq -r '.url // empty' 2>/dev/null)
    if [ -n "$URL" ]; then
      echo ""
      echo "HTTP Health Check:"
      check_http_health "$URL"
    fi
    exit 0
  fi
fi

# Fall back to CLI
if check_cli_auth; then
  if get_sprite_via_cli "$SPRITE_NAME"; then
    exit 0
  fi
else
  print_error "Could not authenticate with sprites CLI"
  echo ""
  echo "Run 'sprite login' to authenticate, or set SPRITES_API_TOKEN"
  exit 1
fi

exit 1
