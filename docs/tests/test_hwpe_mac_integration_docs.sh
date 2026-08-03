#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE="$ROOT/docs/source"
ARCHITECTURE="$ROOT/docs/source/architecture/hwpe-mac.rst"
RUNTIME="$ROOT/docs/source/software-runtime/simple-runtime.rst"
CI="$ROOT/docs/source/verification/ci-pipeline.rst"
SPHINX_BUILD="${SPHINX_BUILD:-$ROOT/.venv/bin/sphinx-build}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

grep -qF '``USE_HWPE`` is enabled by default' "$ARCHITECTURE"
grep -qF '``hwpe_mac_integration``' "$ARCHITECTURE"
grep -qF '``hwpe-mac-engine`` 2.1.4' "$ARCHITECTURE"
grep -qF '``pulp_soc`` 7.0.6' "$ARCHITECTURE"
grep -qF '``include/hal/hwme/hwme_v1.h``' "$RUNTIME"
grep -qF 'scripts/hwpe/run_hwpe_mac_validation.sh' "$CI"
grep -qF 'WNS, WHS, or WPWS is negative' "$CI"
grep -qF 'error-level DRC violation' "$CI"

if grep -qF 'simulation and FPGA tops set ``USE_HWPE`` to zero' "$ARCHITECTURE"; then
  echo 'stale disabled-HWPE status remains in documentation' >&2
  exit 1
fi

mkdir -p \
  "$TMP_DIR/source/architecture" \
  "$TMP_DIR/source/software-runtime" \
  "$TMP_DIR/source/verification" \
  "$TMP_DIR/source/_static"
cp "$ARCHITECTURE" "$TMP_DIR/source/architecture/"
cp "$RUNTIME" "$TMP_DIR/source/software-runtime/"
cp "$CI" "$TMP_DIR/source/verification/"
cp "$SOURCE/_static/hwpe-mac-rtl.svg" "$TMP_DIR/source/_static/"
printf '%s\n' \
  "project = 'HERIS Documentation'" \
  "master_doc = 'index'" \
  "suppress_warnings = ['ref.doc']" \
  >"$TMP_DIR/source/conf.py"
printf '%s\n' \
  'HWPE MAC Integration' \
  '====================' \
  '' \
  '.. toctree::' \
  '' \
  '   architecture/hwpe-mac' \
  '   software-runtime/simple-runtime' \
  '   verification/ci-pipeline' \
  >"$TMP_DIR/source/index.rst"

"$SPHINX_BUILD" -W -b dummy "$TMP_DIR/source" "$TMP_DIR/build" >/dev/null

echo 'PASS: HWPE MAC integration documentation'
