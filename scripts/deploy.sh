#!/usr/bin/env bash
set -euo pipefail

TARGET_ENV="${1:-dev}"

if [ "$TARGET_ENV" = "prod" ]; then
  COMPOSE_FILE="docker-compose.prod.yml"
else
  COMPOSE_FILE="docker-compose.dev.yml"
fi

./scripts/render_env.sh "$TARGET_ENV"

docker compose \
  --env-file .env.runtime \
  -f docker-compose.yml \
  -f "$COMPOSE_FILE" \
  pull

docker compose \
  --env-file .env.runtime \
  -f docker-compose.yml \
  -f "$COMPOSE_FILE" \
  up -d --remove-orphans

docker image prune -f