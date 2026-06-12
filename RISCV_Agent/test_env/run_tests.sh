#!/bin/bash
# TinyRocket RISC-V ISA Test Runner
# Run from test_env/ directory
# Usage: ./run_tests.sh [test_category]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VTEST="$SCRIPT_DIR/build/VTestHarness"
ISA_DIR="/home/cabbage/workspace/EDA_system/AgentForRISCV/riscv-tests/isa"
TIMEOUT=30
MAX_CYCLES=10000000
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"

total=0
passed=0
failed=0
declare -A results

run_test() {
    local binary="$1"
    local name
    name=$(basename "$binary")
    local log="$LOG_DIR/${name}.log"

    total=$((total + 1))
    printf "[%3d] %-35s ... " "$total" "$name"

    local exit_code=0
    timeout $TIMEOUT "$VTEST" +max-cycles=$MAX_CYCLES "$binary" > "$log" 2>&1 || exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "PASS"
        passed=$((passed + 1))
        results["$name"]="PASS"
    elif [ $exit_code -eq 124 ]; then
        echo "TIMEOUT"
        failed=$((failed + 1))
        results["$name"]="TIMEOUT"
    elif [ $exit_code -eq 134 ] || [ $exit_code -eq 135 ]; then
        echo "ABORT (SIGABRT)"
        failed=$((failed + 1))
        results["$name"]="ABORT"
    else
        if grep -q "FAILED" "$log" 2>/dev/null; then
            echo "FAIL (tohost)"
        else
            echo "FAIL (exit=$exit_code)"
        fi
        failed=$((failed + 1))
        results["$name"]="FAIL"
    fi
}

run_category() {
    local cat="$1"
    local label="$2"
    local count=0
    # count non-dump files
    for f in "$ISA_DIR/${cat}-p-"*; do
        [[ "$f" == *.dump ]] && continue
        [ -f "$f" ] && count=$((count + 1))
    done
    if [ $count -eq 0 ]; then
        return
    fi
    echo ""
    echo "--- $label ($cat) ---"
    for binary in "$ISA_DIR/${cat}-p-"*; do
        [[ "$binary" == *.dump ]] && continue
        [ -f "$binary" ] || continue
        run_test "$binary"
    done
}

# Default: run all categories
if [ $# -eq 0 ]; then
    CATEGORIES="rv32ui:RV32UI_Integer rv32um:RV32UM_MulDiv rv32mi:RV32MI_Machine rv32ua:RV32UA_Atomic rv32uc:RV32UC_Compressed"
else
    CATEGORIES="$1"
fi

echo "============================================"
echo "  TinyRocket RISC-V ISA Test Suite"
echo "  Simulator: $VTEST"
echo "============================================"

for cat_pair in $CATEGORIES; do
    cat_name="${cat_pair%%:*}"
    cat_label="${cat_pair##*:}"
    run_category "$cat_name" "$cat_label"
done

echo ""
echo "============================================"
echo "  Results Summary"
echo "============================================"
echo "Total:  $total"
echo "Passed: $passed"
echo "Failed: $failed"
if [ $total -gt 0 ]; then
    echo "Pass Rate: $(( passed * 100 / total ))%"
fi

# Category breakdown
echo ""
echo "--- Category Breakdown ---"
for cat in rv32ui rv32um rv32mi rv32ua rv32uc; do
    cat_total=0
    cat_pass=0
    for key in "${!results[@]}"; do
        if [[ "$key" == ${cat}-* ]]; then
            cat_total=$((cat_total + 1))
            [[ "${results[$key]}" == "PASS" ]] && cat_pass=$((cat_pass + 1))
        fi
    done
    if [ $cat_total -gt 0 ]; then
        printf "  %-8s %2d/%2d (%d%%)\n" "$cat:" "$cat_pass" "$cat_total" "$(( cat_pass * 100 / cat_total ))"
    fi
done

# List failures
if [ $failed -gt 0 ]; then
    echo ""
    echo "--- Failed Tests ---"
    for name in "${!results[@]}"; do
        if [ "${results[$name]}" != "PASS" ]; then
            echo "  $name: ${results[$name]}"
        fi
    done
fi

echo ""
echo "Logs saved to: $LOG_DIR/"
