FROM python:3.11-slim

# git for worktree management, libicu for the .NET-based AL language server
RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl ca-certificates libicu72 procps \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir serena-agent aiohttp

WORKDIR /app
COPY orchestrator.py setup_worktrees.sh sync_worktrees.sh entrypoint.sh ./
RUN chmod +x setup_worktrees.sh sync_worktrees.sh entrypoint.sh

ENV SERENA_DATA_DIR=/data \
    SERENA_WORKTREES=/data/worktrees

EXPOSE 8000
ENTRYPOINT ["./entrypoint.sh"]
CMD ["serve"]
