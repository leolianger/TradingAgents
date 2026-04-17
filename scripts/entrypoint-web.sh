#!/bin/sh
# Wrapper for optional future hooks; env/.env come from Helm (volume + subPath), not from the image.
set -eu
exec "$@"
