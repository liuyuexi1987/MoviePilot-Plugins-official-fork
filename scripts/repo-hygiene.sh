#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/3] fetch --prune origin"
git fetch --prune origin >/dev/null

echo "[2/3] remote/local branch audit"
python3 scripts/audit-remote-branches.py

echo "[3/3] local archive dry-run"
python3 scripts/archive-local-branches.py
