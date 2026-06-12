# Hosted Serena MCP for BC Code History

Serves [Serena](https://github.com/oraios/serena) MCP instances for **all
country branches of one BC major version** of this repository, so the
community can point their AI coding agents (Claude Code, Cursor, Cline, ...)
at Microsoft's Base App source with full AL symbol navigation — without
cloning multi-GB branches locally.

## How it works

```
client ──HTTP──▶ orchestrator (:8000) ──▶ serena instance per branch (lazy)
                                            └─ AL language server
                                            └─ git worktree of {country}-{major}
```

- One bare clone, one **git worktree per branch** (e.g. `w1-28`, `de-28`, ...,
  49 branches for major 28). All worktrees share the packed object store.
- Serena is **stateful with one project per instance**, so the orchestrator
  spawns one Serena process per branch — **on demand**, on first request to
  `/{branch}/mcp` — and stops it after `SERENA_IDLE_TIMEOUT` seconds of
  inactivity. At most `SERENA_MAX_INSTANCES` run concurrently (LRU eviction).
  This bounds memory: the AL language server needs roughly 2–4 GB per
  instance on the Base Application.
- Every project is configured `read_only: true`; Serena's editing tools are
  disabled.

## Quick start

```bash
cd serena-hosting
export SERENA_HOST_TOKEN="$(openssl rand -hex 24)"
docker compose build

# one-time: create worktrees for major 28 (~60-80 GB disk, takes a while)
docker compose run --rm serena-host setup 28

# optional but recommended for the popular branches: pre-build symbol indexes
docker compose run --rm serena-host setup 28 --index

docker compose up -d
```

Daily sync (handles new CUs *and* the force-pushed late-hotfix rewrites; the
build workflows run at midnight UTC, so 04:00 UTC is a safe slot):

```bash
# crontab on the host
0 4 * * * cd /path/to/serena-hosting && docker compose run --rm serena-host sync
```

Put a TLS-terminating reverse proxy (Caddy, nginx, Cloudflare Tunnel) in
front of port 8000 before exposing it publicly.

## Client configuration

`GET /` lists available branches. Clients connect per branch:

```bash
claude mcp add --transport http bc-w1-28 https://your-host/w1-28/mcp \
  --header "Authorization: Bearer <token>"
```

or in JSON-based MCP configs:

```json
{
  "mcpServers": {
    "bc-w1-28": {
      "type": "http",
      "url": "https://your-host/w1-28/mcp",
      "headers": { "Authorization": "Bearer <token>" }
    }
  }
}
```

Notes for users:

- The **first request to a cold branch takes up to a few minutes** while the
  AL language server starts and loads the Base App. Subsequent requests are
  fast.
- If an instance is evicted mid-session the client gets a session error and
  must re-initialize (MCP clients do this automatically on reconnect).
- `w1-*` branches contain the full base code; country branches add
  localization objects on top.

## Sizing

| Component | Estimate (major 28, 49 branches) |
|---|---|
| Bare object store | ~3 GB |
| Worktrees | ~1.5 GB × 49 ≈ 60–80 GB |
| RAM | ~1 GB base + 2–4 GB × `SERENA_MAX_INSTANCES` |
| CPU | spiky during LS startup/indexing, idle otherwise |

A 4 vCPU / 32 GB / 200 GB disk VM runs `SERENA_MAX_INSTANCES=6` comfortably.

## Caveats

- **AL language server licensing**: Serena's AL support uses the language
  server from Microsoft's VS Code AL extension. Verify that running it
  server-side for third parties is acceptable under its license before
  offering this as a public service.
- The orchestrator's bearer token is a single shared community token, not
  per-user auth. Rotate it by restarting with a new `SERENA_HOST_TOKEN`.
- History rewrites on sync invalidate Serena's index cache for the affected
  branch; the next request to that branch is slow again.
