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

# Web terminal: do not auto-run the CLI (exit/Aborted closes the session and shows "Process has exited").
# Optional: load mounted .env into the shell for `echo $DEEPSEEK_API_KEY` etc. Run `python -m cli.main` manually.
RUN printf '%s\n' \
    '[[ $- != *i* ]] && return' \
    'if [ -r /home/appuser/app/.env ]; then' \
    '  set -a' \
    '  . /home/appuser/app/.env' \
    '  set +a' \
    'fi' \
    >> /home/appuser/.bashrc

ENTRYPOINT ["/usr/local/bin/entrypoint-web.sh"]
CMD ["tradingagents"]