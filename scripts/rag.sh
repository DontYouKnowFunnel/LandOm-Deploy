#!/usr/bin/env bash
set -euo pipefail

TARGET_ENV="${1:-dev}"

if [ "$TARGET_ENV" = "prod" ]; then
  COMPOSE_FILE="docker-compose.prod.yml"
  PROJECT_NAME="landom-prod"
else
  COMPOSE_FILE="docker-compose.dev.yml"
  PROJECT_NAME="landom-dev"
fi

./scripts/env.sh "$TARGET_ENV"

docker compose \
  -p "$PROJECT_NAME" \
  --env-file .env.runtime \
  -f docker-compose.yml \
  -f "$COMPOSE_FILE" \
  pull llm

docker compose \
  -p "$PROJECT_NAME" \
  --env-file .env.runtime \
  -f docker-compose.yml \
  -f "$COMPOSE_FILE" \
  up -d qdrant

docker compose \
  -p "$PROJECT_NAME" \
  --env-file .env.runtime \
  -f docker-compose.yml \
  -f "$COMPOSE_FILE" \
  run --rm --no-deps llm \
  sh -lc "
    python scripts/build_rag_vector_db.py --recreate &&
    python scripts/query_rag_vector_db.py
  "