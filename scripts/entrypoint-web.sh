#!/bin/sh
# Seed persistent .env from .env.example and link project root .env for python-dotenv (cli/main.py load_dotenv).
set -eu

APP_ROOT="/home/appuser/app"
EXAMPLE="$APP_ROOT/.env.example"

resolve_data_dir() {
  if [ -n "${TRADINGAGENTS_APPDATA:-}" ] && [ -d "${TRADINGAGENTS_APPDATA}" ]; then
    printf '%s' "$TRADINGAGENTS_APPDATA"
    return
  fi
  # Do not require -w: some hostPath mounts report not writable to uid 1000 even when seed worked (init).
  if [ -d /app/data ]; then
    printf '%s' "/app/data"
    return
  fi
  if [ -d /home/appuser/.tradingagents ]; then
    printf '%s' "/home/appuser/.tradingagents"
    return
  fi
  printf ''
}

if [ -f "$EXAMPLE" ]; then
  DATA_DIR="$(resolve_data_dir)"
  if [ -n "$DATA_DIR" ]; then
    if [ ! -f "$DATA_DIR/.env" ]; then
      cp "$EXAMPLE" "$DATA_DIR/.env"
    fi
    ln -sf "$DATA_DIR/.env" "$APP_ROOT/.env"
  fi
fi

exec "$@"
