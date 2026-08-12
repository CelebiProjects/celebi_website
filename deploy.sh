#!/usr/bin/env bash
# Deploy celebi.labz0.org: build the site and rsync it to the server.
#
# Usage: ./deploy.sh
# Overrides: SSH_HOST=... WEB_ROOT=... SSH_PORT=... ./deploy.sh

set -euo pipefail
cd "$(dirname "$0")"

SSH_HOST="${SSH_HOST:-root@www.labz0.org}"
WEB_ROOT="${WEB_ROOT:-/var/www/celebi.labz0.org}"
SSH_PORT="${SSH_PORT:-28258}"

echo "==> Building site"
hugo --minify

echo "==> Uploading to ${SSH_HOST}:${WEB_ROOT}"
ssh -p "$SSH_PORT" "$SSH_HOST" "mkdir -p '$WEB_ROOT'"
rsync -az --delete -e "ssh -p $SSH_PORT" public/ "$SSH_HOST:$WEB_ROOT/"

echo "==> Done: https://celebi.labz0.org/"
