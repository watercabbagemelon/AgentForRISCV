#!/usr/bin/env bash
# 综合阶段验证：检查综合产物是否存在且无错误
set -euo pipefail

FLOW_DIR="/OpenROAD-flow-scripts/flow"
DESIGN="ALU"
PLATFORM="sky130hd"
RESULTS_DIR="${FLOW_DIR}/results/${PLATFORM}/${DESIGN}/1_synth"
REPORTS_DIR="${FLOW_DIR}/reports/${PLATFORM}/${DESIGN}"

# 读取 stdin（hook 输入），检查是否是综合相关的 Bash 命令
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# 只对包含 1_synth 的命令触发验证
if ! echo "$CMD" | grep -qE '1_synth|make.*DESIGN_CONFIG'; then
  exit 0
fi

echo "[validate_synth] 开始验证综合阶段产物..." >&2

# 检查综合网表是否生成
NETLIST=$(docker exec orfs-agent bash -c "ls ${RESULTS_DIR}/*.v 2>/dev/null | head -1" 2>/dev/null || true)
if [ -z "$NETLIST" ]; then
  MSG="[综合验证失败] 未找到综合网表文件（${RESULTS_DIR}/*.v）。综合可能未完成或发生错误，请检查综合日志。"
  echo "$MSG" >&2
  jq -n --arg msg "$MSG" '{
    "continue": false,
    "stopReason": $msg,
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": $msg
    }
  }'
  exit 0
fi

# 检查综合日志中是否有 ERROR
LOG_ERRORS=$(docker exec orfs-agent bash -c "grep -i '^Error\|^ERROR\|\[ERROR\]' ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/1_1_yosys.log 2>/dev/null | head -20" 2>/dev/null || true)
if [ -n "$LOG_ERRORS" ]; then
  MSG="[综合验证失败] 综合日志中发现错误：
${LOG_ERRORS}
请修复上述错误后重新运行综合。"
  echo "$MSG" >&2
  jq -n --arg msg "$MSG" '{
    "continue": false,
    "stopReason": $msg,
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": $msg
    }
  }'
  exit 0
fi

# 检查单元数量（网表不应为空）
CELL_COUNT=$(docker exec orfs-agent bash -c "grep -c 'sky130' ${NETLIST} 2>/dev/null || echo 0" 2>/dev/null || echo "0")
if [ "$CELL_COUNT" -eq 0 ]; then
  MSG="[综合验证失败] 综合网表中未找到标准单元实例（sky130 cells），网表可能为空或综合失败。"
  echo "$MSG" >&2
  jq -n --arg msg "$MSG" '{
    "continue": false,
    "stopReason": $msg,
    "hookSpecificOutput": {
      "hookEventName": "PostToolUse",
      "additionalContext": $msg
    }
  }'
  exit 0
fi

echo "[validate_synth] 综合验证通过：网表已生成，包含 ${CELL_COUNT} 个标准单元实例。" >&2
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "综合验证通过：网表已生成且包含标准单元实例。"
  }
}'
