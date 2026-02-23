---
name: check-sprite-state
description: Check the current state and status of sprites.dev sprites. Use this to query sprite information, verify connectivity, monitor running services, and retrieve API details for a named sprite. Works with the sprites.dev CLI or REST API.
compatibility: Requires sprites.dev CLI installed via curl -fsSL https://sprites.dev/install.sh | sh, or a valid SPRITES_API_TOKEN for direct API access.
metadata:
  author: claude-code
  version: "1.0"
---

# Check Sprite State Skill

This skill provides methods to query and monitor the state of sprites.dev sprite environments.

## Overview

Sprites are persistent, hardware-isolated Linux environments. This skill helps you:
- Check if a sprite is running, cold, or idle
- Retrieve sprite information (URL, status, organization)
- Verify sprite connectivity and service health
- Monitor sprite state changes over time

## Prerequisites

Choose one of these authentication methods:

### Method 1: CLI (Recommended for interactive use)
Ensure the sprites.dev CLI is installed:
```bash
curl -fsSL https://sprites.dev/install.sh | sh
sprite login
```

### Method 2: API Token (For CI/CD and automation)
Set up authentication with an API token:
```bash
export PATH="$PATH:~/.local/bin"
sprite auth setup --token "your-org/token-id/token-value"
```

Or use the API token directly with curl:
```bash
SPRITES_API_TOKEN="your-token-value"
```

## Usage Examples

### Check Single Sprite Status via CLI

```bash
export PATH="$PATH:~/.local/bin"
sprite list --prefix jodi-daniel-portfolio
```

Output includes sprite name, organization, and status.

### Get Detailed Sprite Info via API

```bash
SPRITES_API_TOKEN="your-api-token"
curl -s -H "Authorization: Bearer $SPRITES_API_TOKEN" \
  "https://api.sprites.dev/v1/sprites/jodi-daniel-portfolio" | jq .
```

Response includes:
- `name`: Sprite identifier
- `status`: Current state (e.g., "running", "cold", "idle")
- `url`: Public sprite URL
- `created_at`, `updated_at`: Timestamps
- `org`: Organization ID

### Check All Sprites in Organization

```bash
export PATH="$PATH:~/.local/bin"
sprite list
```

Or via API:
```bash
curl -s -H "Authorization: Bearer $SPRITES_API_TOKEN" \
  "https://api.sprites.dev/v1/sprites?limit=100" | jq .
```

### Get Sprite Status in a Script

```bash
#!/bin/bash
SPRITE_NAME="jodi-daniel-portfolio"
SPRITES_API_TOKEN="${SPRITES_API_TOKEN:-}"

if [ -z "$SPRITES_API_TOKEN" ]; then
  echo "Error: SPRITES_API_TOKEN not set"
  exit 1
fi

RESPONSE=$(curl -s \
  -H "Authorization: Bearer $SPRITES_API_TOKEN" \
  "https://api.sprites.dev/v1/sprites/$SPRITE_NAME")

# Extract relevant fields
echo "$RESPONSE" | jq '{
  name: .name,
  status: .status,
  url: .url,
  updated_at: .updated_at
}'
```

### Monitor Sprite Service Health

Combine status checks with HTTP health checks:

```bash
SPRITE_URL="https://jodi-daniel-portfolio-blpx4.sprites.app"

# Check if sprite is responding
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SPRITE_URL")

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "✓ Sprite is healthy (HTTP $HTTP_STATUS)"
else
  echo "✗ Sprite returned HTTP $HTTP_STATUS"
fi
```

## Sprite Status Values

- **running**: Sprite is currently active and processing requests
- **warm**: Sprite was recently active and can respond immediately
- **cold**: Sprite is idle but filesystem preserved; may take a moment to respond
- **error**: Sprite encountered an issue
- **destroyed**: Sprite has been removed

## Common Patterns

### Check Before Operations
```bash
# Verify sprite exists and is accessible before deploying
SPRITE_STATUS=$(curl -s \
  -H "Authorization: Bearer $SPRITES_API_TOKEN" \
  "https://api.sprites.dev/v1/sprites/my-sprite" | jq -r '.status')

if [ "$SPRITE_STATUS" != "error" ]; then
  echo "Sprite ready, proceeding with deployment..."
  # Deploy files or commands
else
  echo "Sprite is in error state, aborting"
  exit 1
fi
```

### Wait for Sprite to Wake
```bash
# Poll sprite status until it's responsive
wait_for_sprite() {
  local sprite_name=$1
  local max_attempts=30
  local attempt=0

  while [ $attempt -lt $max_attempts ]; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      "https://${sprite_name}-xxxx.sprites.app")

    if [ "$STATUS" -eq 200 ]; then
      echo "Sprite is responsive"
      return 0
    fi

    attempt=$((attempt + 1))
    echo "Waiting for sprite... (attempt $attempt/$max_attempts)"
    sleep 2
  done

  echo "Sprite did not become responsive in time"
  return 1
}

wait_for_sprite "my-sprite"
```

### Export Sprite Info for Use in Other Commands
```bash
# Get sprite URL and store for use in next command
SPRITE_URL=$(curl -s \
  -H "Authorization: Bearer $SPRITES_API_TOKEN" \
  "https://api.sprites.dev/v1/sprites/my-sprite" | jq -r '.url')

# Use URL in subsequent operations
curl -s "$SPRITE_URL/api/health"
```

## Troubleshooting

### "No organizations configured" error
This means the sprites CLI isn't authenticated. Run:
```bash
sprite login
```
Or use an API token with the CLI:
```bash
sprite auth setup --token "org/token-id/token-value"
```

### 401 Unauthorized with API calls
The SPRITES_API_TOKEN is invalid or missing. Verify:
- Token is set: `echo $SPRITES_API_TOKEN`
- Token has required permissions
- Token hasn't expired

### 404 Not Found
The sprite name doesn't exist. Verify the sprite name:
```bash
sprite list
```

### Slow Response Times
The sprite may be in "cold" state (idle). This is normal. Cold sprites:
- Have preserved filesystems
- Take a few seconds to respond
- Incur no compute charges while idle

## References

- [Sprites.dev Documentation](https://docs.sprites.dev)
- [Sprites API Reference](https://docs.sprites.dev/api/v001-rc30/sprites/)
- [CLI Commands](https://docs.sprites.dev/cli/commands/)
