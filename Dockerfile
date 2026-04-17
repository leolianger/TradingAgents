FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /build
COPY . .
RUN pip install --no-cache-dir .

FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY scripts/entrypoint-web.sh /usr/local/bin/entrypoint-web.sh
RUN chmod 755 /usr/local/bin/entrypoint-web.sh

RUN useradd --create-home appuser
USER appuser
WORKDIR /home/appuser/app

COPY --from=builder --chown=appuser:appuser /build .

# Do not customize .bashrc: web terminal + `source .env` can exit the session if .env is not valid shell
# syntax; `beclab/terminal` works like context7 (no --shell flag). Use `python -m cli.main` manually;
# `load_dotenv()` still reads /home/appuser/app/.env for the CLI process.

ENTRYPOINT ["/usr/local/bin/entrypoint-web.sh"]
CMD ["tradingagents"]