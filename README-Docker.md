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

**`.env` on Olares**

Handled by the **Helm chart** (`terminus-apps/tradingagents`): **`templates/configmap-dotenv.yaml`** defines the default keys (inline text; Olares does not support Helm `.Files.Get`). Init seeds the volume **`.env`** once; the Deployment mounts it at **`/home/appuser/app/.env`** (subPath, same idea as **nofx**). Edit **`.env`** under the app **Data/…** folder on the host; no image-side copy.

**Image size**: The image can be around 1.5–1.6GB. That is normal for this stack: `python:3.12-slim` plus pandas, langchain, backtrader, yfinance and their dependencies pull in a lot of code. To reduce size you can: pin exact versions in `requirements.txt`, add more paths to `.dockerignore` (e.g. `tests/`, `docs/`), or use a multi-stage build that copies only a built venv (advanced).
