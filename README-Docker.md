# Docker build and push (goai007)

Build and push to Docker Hub as `goai007/tradingagents`:

```bash
docker build -t goai007/tradingagents:0.2.1 .
docker push goai007/tradingagents:0.2.1
```

Optional: tag latest and push:

```bash
docker tag goai007/tradingagents:0.2.1 goai007/tradingagents:latest
docker push goai007/tradingagents:latest
```

Olares deployment uses the image from `terminus-apps/tradingagents` (Chart + OlaresManifest); image is built and published from this repo only.

**`.env` on Olares (persistent volume `/app/data`)**

The image ships `.env.example`. `entrypoint-web.sh` runs before the main process:

1. If `/app/data/.env` does not exist, it copies `.env.example` → `/app/data/.env`.
2. It symlinks `/home/appuser/app/.env` → `/app/data/.env`.

Upstream `cli/main.py` uses `load_dotenv()` against the project root, so editing **`/app/data/.env`** (or the same keys via the symlinked file) applies after `python -m cli.main` with no code changes.

With Docker Compose, the same logic uses the volume mount **`/home/appuser/.tradingagents`** when `/app/data` is absent.

**Image size**: The image can be around 1.5–1.6GB. That is normal for this stack: `python:3.12-slim` plus pandas, langchain, backtrader, yfinance and their dependencies pull in a lot of code. To reduce size you can: pin exact versions in `requirements.txt`, add more paths to `.dockerignore` (e.g. `tests/`, `docs/`), or use a multi-stage build that copies only a built venv (advanced).
