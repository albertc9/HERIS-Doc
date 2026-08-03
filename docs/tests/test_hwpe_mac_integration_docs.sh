#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARCHITECTURE="$ROOT/docs/source/architecture/hwpe-mac.rst"
RUNTIME="$ROOT/docs/source/software-runtime/simple-runtime.rst"
CI="$ROOT/docs/source/verification/ci-pipeline.rst"

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

echo 'PASS: HWPE MAC integration documentation'
