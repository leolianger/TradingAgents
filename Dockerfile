# Use 3.12: numpy<2 (required by langchain-experimental) has no 3.13 wheel, so 3.13 would need build deps.
FROM python:3.12-slim

WORKDIR /app

# Install package from pyproject (requirements.txt is only "." for local editable installs — needs these paths first).
COPY pyproject.toml README.md ./
COPY tradingagents ./tradingagents
COPY cli ./cli

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -e .

# Runtime entry (Olares) + static UI
COPY serve.py ./
COPY web_ui ./web_ui/

ENV PORT=8080
EXPOSE 8080
CMD ["python", "serve.py"]
