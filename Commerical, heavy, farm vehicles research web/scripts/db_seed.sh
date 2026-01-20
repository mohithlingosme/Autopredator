#!/usr/bin/env bash
set -euo pipefail

# Seed the AutoPredator database with deterministic demo data.
MODE=${MODE:-medium}
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$ROOT_DIR/apps/api/.env" ]; then
  # shellcheck source=/dev/null
  set -a
  source "$ROOT_DIR/apps/api/.env"
  set +a
fi

export PYTHONPATH="$ROOT_DIR"

echo "[SEED] Running mode='$MODE'"
python "$ROOT_DIR/apps/api/seed/seed.py" --mode "$MODE"
