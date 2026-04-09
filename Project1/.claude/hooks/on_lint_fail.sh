#!/bin/bash

echo "[HOOK] Lint failed. Preparing auto-fix..."

echo "===== LINT LOG ====="
cat sim/logs/lint.log

echo "===== END LOG ====="

echo "[HOOK] Please fix the Verilog/Chisel code based on lint errors."
