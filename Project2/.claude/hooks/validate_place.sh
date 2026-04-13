#!/usr/bin/env bash
# 布局阶段验证：检查布局产物（DEF/ODB）是否存在且无违规
set -euo pipefail

FLOW_DIR="/OpenROAD-flow-scripts/flow"
DESIGN="ALU"
PLATFORM="sky130hd"
RESULTS_DIR="${FLOW_DIR}/results/${PLATFORM}/${DESIGN}"

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$CMD" | grep -qE '3_place|make.*DESIGN_CONFIG'; then
  exit 0
fi

echo "[validate_place] 开始验证布局阶段产物..." >&2

# 检查布局后 DEF 文件
PLACE_DEF=$(docker exec orfs-agent bash -c "ls ${RESULTS_DIR}/3_place.def 2>/dev/null" 2>/dev/null || true)
if [ -z "$PLACE_DEF" ]; then
  MSG="[布局验证失败] 未找到布局结果文件（${RESULTS_DIR}/3_place.def）。布局阶段可能未完成，请检查布局日志。"
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

# 检查布局日志中的错误
LOG_ERRORS=$(docker exec orfs-agent bash -c "grep -i '^Error\|^ERROR\|\[ERROR\]' \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/3_1_place.log \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/3_2_place.log \
  2>/dev/null | head -20" 2>/dev/null || true)
if [ -n "$LOG_ERRORS" ]; then
  MSG="[布局验证失败] 布局日志中发现错误：
${LOG_ERRORS}
请修复上述错误后重新运行布局。"
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

# 检查布局密度报告中是否有溢出（overflow）
OVERFLOW=$(docker exec orfs-agent bash -c "grep -i 'overflow' \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/3_1_place.log 2>/dev/null | tail -5" 2>/dev/null || true)
if echo "$OVERFLOW" | grep -qiE 'overflow.*[1-9][0-9]*|[1-9][0-9]*.*overflow'; then
  MSG="[布局验证失败] 检测到布局溢出（overflow），可能导致后续布线失败：
${OVERFLOW}
建议降低 PLACE_DENSITY 或增大 DIE_AREA 后重新布局。"
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

echo "[validate_place] 布局验证通过：DEF 文件已生成，无错误和溢出。" >&2
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "布局验证通过：DEF 文件已生成，无错误和溢出。"
  }
}'
