#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
ENV_FILE="${PROJECT_DIR}/.env.supabase"
DB_URL=${SUPABASE_DB_URL:-}

usage() {
    cat <<EOF
Usage:
  scripts/queries.sh

Runs the SQL queries in dql/Swiftride_logistics_dql.sql against Supabase.

Set SUPABASE_DB_URL in your shell or create:
  ${ENV_FILE}
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ -z "$DB_URL" && -f "$ENV_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$ENV_FILE"
    DB_URL=${SUPABASE_DB_URL:-}
fi

if [[ -z "$DB_URL" ]]; then
    echo "SUPABASE_DB_URL is not set." >&2
    usage
    exit 1
fi

if ! command -v psql >/dev/null 2>&1; then
    echo "psql is required but was not found in PATH." >&2
    exit 1
fi

echo "Running SwiftRide DQL queries"
psql "$DB_URL" \
    -v ON_ERROR_STOP=1 \
    -P pager=off \
    -f "${PROJECT_DIR}/dql/Swiftride_logistics_dql.sql"
