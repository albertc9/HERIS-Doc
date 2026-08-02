#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE="$ROOT/docs/source/bendis"
SPHINX_BUILD="${SPHINX_BUILD:-$ROOT/.venv/bin/sphinx-build}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

grep -qF 'Bendis 0.6.4' "$SOURCE/bendis-install.rst"
grep -qF 'Bender ``>=0.32.1,<0.33.0``' "$SOURCE/bendis-install.rst"
grep -qF 'bendis local-inputs --json' "$SOURCE/bendis-for-development.rst"
grep -qF '# BEGIN BENDIS MANAGED INPUTS' "$SOURCE/bendis-config.rst"
grep -qF 'bendis init --force' "$SOURCE/bendis-config.rst"
grep -qF 'does not modify the project-root ``.gitignore``' "$SOURCE/bendis-config.rst"
grep -qF 'supported only from the ``heris-soc`` project root' "$SOURCE/bendis-for-hardening.rst"

if grep -qF 'If no local Path dependency is configured, it uses ``hw/`` and ``target/``.' \
  "$SOURCE/bendis-for-development.rst"; then
  echo 'stale local-input fallback remains in Bendis documentation' >&2
  exit 1
fi

mkdir -p "$TMP_DIR/source"
cp "$SOURCE"/*.rst "$TMP_DIR/source/"
printf '%s\n' \
  "project = 'HERIS Documentation'" \
  "master_doc = 'index'" \
  >"$TMP_DIR/source/conf.py"
printf '%s\n' \
  'Bendis' \
  '======' \
  '' \
  '.. toctree::' \
  '' \
  '   bendis-install' \
  '   bendis-config' \
  '   bendis-for-development' \
  '   bendis-for-hardening' \
  >"$TMP_DIR/source/index.rst"

"$SPHINX_BUILD" -W -b dummy "$TMP_DIR/source" "$TMP_DIR/build" >/dev/null

echo 'PASS: Bendis documentation'
