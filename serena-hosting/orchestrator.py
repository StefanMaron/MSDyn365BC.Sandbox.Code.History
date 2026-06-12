"""On-demand multi-branch Serena MCP host.

Routes /{branch}/mcp to a per-branch Serena instance (streamable-http),
spawning instances lazily on first request and stopping them after an idle
timeout. This keeps memory bounded: only branches in active use run an AL
language server.

Environment:
    SERENA_WORKTREES      directory with one worktree per branch (default /data/worktrees)
    SERENA_HOST_TOKEN     if set, clients must send "Authorization: Bearer <token>"
    SERENA_MAX_INSTANCES  concurrent Serena instances; LRU-evicted beyond this (default 6)
    SERENA_IDLE_TIMEOUT   seconds before an unused instance is stopped (default 1800)
    SERENA_LISTEN_PORT    public listen port (default 8000)
    SERENA_LOG_DIR        per-instance serena logs (default /data/logs)
"""

import asyncio
import logging
import os
import re
import socket
import time
from pathlib import Path

import aiohttp
from aiohttp import web

WORKTREES = Path(os.environ.get("SERENA_WORKTREES", "/data/worktrees"))
TOKEN = os.environ.get("SERENA_HOST_TOKEN", "")
MAX_INSTANCES = int(os.environ.get("SERENA_MAX_INSTANCES", "6"))
IDLE_TIMEOUT = int(os.environ.get("SERENA_IDLE_TIMEOUT", "1800"))
LISTEN_PORT = int(os.environ.get("SERENA_LISTEN_PORT", "8000"))
LOG_DIR = Path(os.environ.get("SERENA_LOG_DIR", "/data/logs"))
SPAWN_TIMEOUT = 180

BRANCH_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]*$")
HOP_BY_HOP = {
    "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
    "te", "trailers", "transfer-encoding", "upgrade", "host", "authorization",
}

log = logging.getLogger("serena-host")


class Instance:
    def __init__(self, branch: str, port: int, proc: asyncio.subprocess.Process):
        self.branch = branch
        self.port = port
        self.proc = proc
        self.last_used = time.monotonic()


class Host:
    def __init__(self):
        self.instances: dict[str, Instance] = {}
        self.lock = asyncio.Lock()
        self.session: aiohttp.ClientSession | None = None

    @staticmethod
    def _free_port() -> int:
        with socket.socket() as s:
            s.bind(("127.0.0.1", 0))
            return s.getsockname()[1]

    async def _wait_ready(self, port: int, proc: asyncio.subprocess.Process):
        deadline = time.monotonic() + SPAWN_TIMEOUT
        while time.monotonic() < deadline:
            if proc.returncode is not None:
                raise RuntimeError(f"serena exited with code {proc.returncode}")
            try:
                _, writer = await asyncio.open_connection("127.0.0.1", port)
                writer.close()
                await writer.wait_closed()
                return
            except OSError:
                await asyncio.sleep(1)
        raise RuntimeError("serena did not become ready in time")

    async def _stop(self, inst: Instance):
        log.info("stopping instance for %s", inst.branch)
        if inst.proc.returncode is None:
            inst.proc.terminate()
            try:
                await asyncio.wait_for(inst.proc.wait(), timeout=15)
            except asyncio.TimeoutError:
                inst.proc.kill()
                await inst.proc.wait()

    async def ensure_instance(self, branch: str) -> Instance:
        async with self.lock:
            inst = self.instances.get(branch)
            if inst is not None and inst.proc.returncode is None:
                inst.last_used = time.monotonic()
                return inst
            if inst is not None:
                del self.instances[branch]

            while len(self.instances) >= MAX_INSTANCES:
                lru = min(self.instances.values(), key=lambda i: i.last_used)
                del self.instances[lru.branch]
                await self._stop(lru)

            port = self._free_port()
            LOG_DIR.mkdir(parents=True, exist_ok=True)
            logfile = open(LOG_DIR / f"{branch}.log", "ab")
            log.info("spawning instance for %s on port %d", branch, port)
            proc = await asyncio.create_subprocess_exec(
                "serena", "start-mcp-server",
                "--transport", "streamable-http",
                "--host", "127.0.0.1",
                "--port", str(port),
                "--project", str(WORKTREES / branch),
                stdout=logfile, stderr=logfile,
            )
            try:
                await self._wait_ready(port, proc)
            except RuntimeError:
                if proc.returncode is None:
                    proc.kill()
                    await proc.wait()
                raise
            inst = Instance(branch, port, proc)
            self.instances[branch] = inst
            return inst

    async def reaper(self):
        while True:
            await asyncio.sleep(30)
            async with self.lock:
                now = time.monotonic()
                idle = [i for i in self.instances.values()
                        if now - i.last_used > IDLE_TIMEOUT or i.proc.returncode is not None]
                for inst in idle:
                    del self.instances[inst.branch]
                    await self._stop(inst)

    # ------------------------------------------------------------- handlers

    def _authorized(self, request: web.Request) -> bool:
        return not TOKEN or request.headers.get("Authorization") == f"Bearer {TOKEN}"

    async def handle_index(self, request: web.Request) -> web.Response:
        if not self._authorized(request):
            return web.json_response({"error": "unauthorized"}, status=401)
        branches = sorted(p.name for p in WORKTREES.iterdir() if p.is_dir())
        return web.json_response({
            "branches": branches,
            "running": sorted(self.instances.keys()),
            "usage": "connect your MCP client to /{branch}/mcp",
        })

    async def handle_proxy(self, request: web.Request) -> web.StreamResponse:
        if not self._authorized(request):
            return web.json_response({"error": "unauthorized"}, status=401)

        branch = request.match_info["branch"]
        if not BRANCH_RE.match(branch) or not (WORKTREES / branch).is_dir():
            return web.json_response({"error": f"unknown branch {branch!r}"}, status=404)

        try:
            inst = await self.ensure_instance(branch)
        except RuntimeError as e:
            log.error("failed to start instance for %s: %s", branch, e)
            return web.json_response({"error": f"failed to start serena: {e}"}, status=502)
        inst.last_used = time.monotonic()

        url = f"http://127.0.0.1:{inst.port}/{request.match_info['tail']}"
        headers = {k: v for k, v in request.headers.items() if k.lower() not in HOP_BY_HOP}
        body = request.content if request.body_exists else None

        async with self.session.request(
            request.method, url, headers=headers, data=body,
            params=request.rel_url.query,
            timeout=aiohttp.ClientTimeout(total=None, sock_read=None),
        ) as resp:
            inst.last_used = time.monotonic()
            out_headers = {k: v for k, v in resp.headers.items() if k.lower() not in HOP_BY_HOP}
            out = web.StreamResponse(status=resp.status, headers=out_headers)
            await out.prepare(request)
            async for chunk in resp.content.iter_any():
                await out.write(chunk)
                inst.last_used = time.monotonic()
            await out.write_eof()
            return out

    # ------------------------------------------------------------ lifecycle

    async def on_startup(self, app: web.Application):
        self.session = aiohttp.ClientSession(auto_decompress=False)
        app["reaper"] = asyncio.create_task(self.reaper())

    async def on_cleanup(self, app: web.Application):
        app["reaper"].cancel()
        async with self.lock:
            for inst in list(self.instances.values()):
                await self._stop(inst)
            self.instances.clear()
        await self.session.close()


def main():
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(name)s %(levelname)s %(message)s")
    if not WORKTREES.is_dir():
        raise SystemExit(f"worktrees directory {WORKTREES} not found - run setup_worktrees.sh first")
    if not TOKEN:
        log.warning("SERENA_HOST_TOKEN not set - server is unauthenticated")

    host = Host()
    app = web.Application()
    app.on_startup.append(host.on_startup)
    app.on_cleanup.append(host.on_cleanup)
    app.add_routes([
        web.get("/", host.handle_index),
        web.route("*", "/{branch}/{tail:.*}", host.handle_proxy),
    ])
    web.run_app(app, host="0.0.0.0", port=LISTEN_PORT)


if __name__ == "__main__":
    main()
