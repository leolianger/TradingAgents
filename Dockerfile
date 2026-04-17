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

# Web terminal on Olares: exec sessions may not inherit pod env — sync from PID 1 (serve.py)
# before running the CLI. See scripts/sync_pod_env.py.
RUN printf '%s\n' \
    'if [[ -r /proc/1/environ ]]; then' \
    '  eval "$(/opt/venv/bin/python /home/appuser/app/scripts/sync_pod_env.py 2>/dev/null)" || true' \
    'fi' \
    '' \
    '[[ $- != *i* ]] && return' \
    '[[ -t 1 ]] || return' \
    '[[ -n "$TA_SKIP_AUTOCLI" ]] && return' \
    'cd /home/appuser/app && /opt/venv/bin/python -m cli.main' \
    >> /home/appuser/.bashrc

ENTRYPOINT ["/usr/local/bin/entrypoint-web.sh"]
CMD ["tradingagents"]