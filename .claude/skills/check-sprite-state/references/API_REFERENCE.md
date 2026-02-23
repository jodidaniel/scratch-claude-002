# Sprites.dev API Reference

## Authentication

All API endpoints require authentication via Bearer token in the Authorization header:

```
Authorization: Bearer YOUR_API_TOKEN
```

API tokens are obtained from the sprites.dev dashboard and have the format:
```
org-name/token-id/token-value
```

## Endpoints

### Get Sprite Info
**GET** `/v1/sprites/{name}`

Returns detailed information about a specific sprite.

**Parameters:**
- `name` (path): The name of the sprite

**Response:**
```json
{
  "name": "my-sprite",
  "status": "running",
  "url": "https://my-sprite-xxxx.sprites.app",
  "org": "my-org",
  "created_at": "2026-02-20T10:30:00Z",
  "updated_at": "2026-02-23T15:45:00Z",
  "auth": {
    "type": "public"
  }
}
```

**Status codes:**
- `200`: Success
- `401`: Unauthorized (invalid token)
- `404`: Sprite not found
- `429`: Rate limited

**Example:**
```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://api.sprites.dev/v1/sprites/my-sprite
```

### List Sprites
**GET** `/v1/sprites`

Returns all sprites in the authenticated organization.

**Query Parameters:**
- `limit` (optional): Max results to return (default: 50, max: 1000)
- `offset` (optional): Pagination offset
- `prefix` (optional): Filter by name prefix

**Response:**
```json
{
  "sprites": [
    {
      "name": "my-sprite",
      "status": "running",
      "url": "https://my-sprite-xxxx.sprites.app",
      "org": "my-org",
      "created_at": "2026-02-20T10:30:00Z",
      "updated_at": "2026-02-23T15:45:00Z"
    }
  ],
  "total": 1
}
```

**Example:**
```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://api.sprites.dev/v1/sprites?limit=100
```

## File Operations

### Write File
**PUT** `/v1/sprites/{name}/fs/write?path={path}`

Write or overwrite a file on the sprite's filesystem.

**Query Parameters:**
- `path`: Absolute path on sprite (required)
- `mkdir`: Create parent directories if true (optional)
- `mode`: File permissions in octal (optional)

**Headers:**
- `Content-Type: application/octet-stream`

**Example:**
```bash
curl -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @file.txt \
  "https://api.sprites.dev/v1/sprites/my-sprite/fs/write?path=/home/user/file.txt"
```

### Read File
**GET** `/v1/sprites/{name}/fs/read?path={path}`

Read a file from the sprite's filesystem.

**Query Parameters:**
- `path`: Absolute path on sprite (required)

**Example:**
```bash
curl -H "Authorization: Bearer $TOKEN" \
  https://api.sprites.dev/v1/sprites/my-sprite/fs/read?path=/home/user/file.txt
```

## Command Execution

### Execute Command
**POST** `/v1/sprites/{name}/exec`

Execute a command on the sprite.

**Request Body:**
```json
{
  "cmd": "command-name",
  "args": ["arg1", "arg2"],
  "env": {
    "KEY": "value"
  }
}
```

**Example:**
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"cmd":"ls","args":["-la"]}' \
  https://api.sprites.dev/v1/sprites/my-sprite/exec
```

## Services API

### Create/Update Service
**PUT** `/v1/sprites/{name}/services/{service-name}`

Register or update a persistent service (auto-starts when sprite wakes).

**Request Body:**
```json
{
  "cmd": "service-command",
  "args": ["arg1", "arg2"],
  "http_port": 8080
}
```

**Example:**
```bash
curl -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "cmd": "python",
    "args": ["-m", "http.server", "8080"],
    "http_port": 8080
  }' \
  https://api.sprites.dev/v1/sprites/my-sprite/services/web
```

## Checkpoints

### Create Checkpoint
**POST** `/v1/sprites/{name}/checkpoint`

Create a snapshot of the sprite's current state.

**Request Body:**
```json
{
  "description": "Optional description"
}
```

### List Checkpoints
**GET** `/v1/sprites/{name}/checkpoints`

Retrieve all checkpoints for a sprite.

### Restore from Checkpoint
**POST** `/v1/sprites/{name}/restore/{checkpoint-id}`

Restore sprite from a checkpoint.

## Status Values

Sprites have the following possible status values:

| Status | Meaning |
|--------|---------|
| `running` | Sprite is currently active |
| `warm` | Sprite recently was active and responds immediately |
| `cold` | Sprite is idle; filesystem preserved, may take seconds to respond |
| `starting` | Sprite is being initialized |
| `stopping` | Sprite is shutting down |
| `error` | Sprite encountered an error |
| `destroyed` | Sprite has been deleted |

## Rate Limiting

The API implements rate limiting:
- **Burst limit**: 100 requests per second
- **Sustained limit**: 1000 requests per minute

When rate limited, the API returns:
- HTTP 429 (Too Many Requests)
- `Retry-After` header with seconds to wait

## Error Responses

All errors include a JSON response:

```json
{
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

**Common error codes:**
- `UNAUTHORIZED`: Invalid or missing token
- `NOT_FOUND`: Sprite doesn't exist
- `INVALID_REQUEST`: Malformed request
- `INTERNAL_ERROR`: Server error

## Examples

### Monitor Sprite Over Time

```bash
#!/bin/bash
TOKEN="$SPRITES_API_TOKEN"
SPRITE="my-sprite"

while true; do
  STATUS=$(curl -s \
    -H "Authorization: Bearer $TOKEN" \
    "https://api.sprites.dev/v1/sprites/$SPRITE" \
    | jq -r '.status')

  echo "$(date): Sprite status is $STATUS"
  sleep 10
done
```

### Check All Sprites in Organization

```bash
curl -s \
  -H "Authorization: Bearer $SPRITES_API_TOKEN" \
  "https://api.sprites.dev/v1/sprites?limit=1000" \
  | jq '.sprites[] | {name, status}'
```

### Deploy a File and Execute

```bash
TOKEN="$SPRITES_API_TOKEN"
SPRITE="my-sprite"

# Upload file
curl -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @script.sh \
  "https://api.sprites.dev/v1/sprites/$SPRITE/fs/write?path=/tmp/script.sh&mode=755"

# Execute it
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"cmd":"bash","args":["/tmp/script.sh"]}' \
  "https://api.sprites.dev/v1/sprites/$SPRITE/exec"
```
