#!/bin/bash
set +e

echo "[HOOK] Running Verilator lint..."

SV_FILES=$(find generated -type f \( -name "*.v" -o -name "*.sv" \))

if [ -z "$SV_FILES" ]; then
    echo "[HOOK] ERROR: No Verilog files found"
    exit 1
fi

echo "[HOOK] Checking files:"
echo "$SV_FILES"

verilator --lint-only $SV_FILES > sim/logs/lint.log 2>&1

if grep -q "%Error" sim/logs/lint.log; then
    echo "[HOOK] Lint ERROR detected"
    exit 1
else
    echo "[HOOK] Lint PASSED (warnings allowed)"
    exit 0
fi
