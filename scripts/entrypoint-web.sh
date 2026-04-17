#!/bin/sh
# Persisted keys live in /app/data/.env (Helm volume). Symlink for upstream load_dotenv() at project root.
# Avoid mounting subPath .env twice in one pod (two containers) — some CNIs/kubelet versions misbehave.
if [ -f /app/data/.env ]; then
  ln -sf /app/data/.env /home/appuser/app/.env
fi
exec "$@"
