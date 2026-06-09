#!/usr/bin/env bash

set -euo pipefail

PYTHON_BIN="/Users/sulaimon/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

if [[ ! -x "$PYTHON_BIN" ]]; then
    echo "Bundled Python runtime was not found: ${PYTHON_BIN}" >&2
    exit 1
fi

"$PYTHON_BIN" "${SCRIPT_DIR}/management_report_pdf.py" "$@"
