#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE="$ROOT/docs/source"
SPHINX_BUILD="${SPHINX_BUILD:-$ROOT/.venv/bin/sphinx-build}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

test -f "$SOURCE/verification/ci-pipeline.rst"
grep -qxF "   verification/ci-pipeline" "$SOURCE/index.rst"

mkdir -p "$TMP_DIR/source"
cp "$SOURCE/verification/ci-pipeline.rst" "$TMP_DIR/source/"
printf '%s\n' \
  "project = 'HERIS Documentation'" \
  "master_doc = 'index'" \
  >"$TMP_DIR/source/conf.py"
printf '%s\n' \
  "CI Pipeline" \
  "===========" \
  "" \
  ".. toctree::" \
  "" \
  "   ci-pipeline" \
  >"$TMP_DIR/source/index.rst"

"$SPHINX_BUILD" -W -b dummy "$TMP_DIR/source" "$TMP_DIR/build" >/dev/null

echo "PASS: CI pipeline documentation"
