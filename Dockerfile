# Use 3.12: numpy<2 (required by langchain-experimental) has no 3.13 wheel, so 3.13 would need build deps.
FROM python:3.12-slim

WORKDIR /app

# Dependency layer (cache-friendly)
COPY pyproject.toml README.md ./
COPY tradingagents ./tradingagents
COPY cli ./cli

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -e .

# Full tree for runtime (serve.py, web_ui if present, etc. — no COPY of a single path that may be missing on CI)
COPY . .

# Ensure Olares HTTP entrance always has a page (repo may omit web_ui/ or it may not be tracked in git)
RUN mkdir -p web_ui \
    && if [ ! -f web_ui/index.html ]; then \
         printf '%s\n' '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>TradingAgents</title></head><body><h1>TradingAgents</h1><p>Use the CLI in the container, e.g. <code>python -m cli.main</code>.</p></body></html>' \
         > web_ui/index.html; \
       fi

ENV PORT=8080
EXPOSE 8080
CMD ["python", "serve.py"]
