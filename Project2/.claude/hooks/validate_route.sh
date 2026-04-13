#!/usr/bin/env bash
# 布线阶段验证：检查布线产物并验证 DRC 违规为 0
set -euo pipefail

FLOW_DIR="/OpenROAD-flow-scripts/flow"
DESIGN="ALU"
PLATFORM="sky130hd"
RESULTS_DIR="${FLOW_DIR}/results/${PLATFORM}/${DESIGN}"

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$CMD" | grep -qE '5_route|make.*DESIGN_CONFIG'; then
  exit 0
fi

echo "[validate_route] 开始验证布线阶段产物..." >&2

# 检查布线后 DEF 文件
ROUTE_DEF=$(docker exec orfs-agent bash -c "ls ${RESULTS_DIR}/5_route.def 2>/dev/null" 2>/dev/null || true)
if [ -z "$ROUTE_DEF" ]; then
  MSG="[布线验证失败] 未找到布线结果文件（${RESULTS_DIR}/5_route.def）。布线阶段可能未完成，请检查布线日志。"
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

# 检查布线日志中的错误
LOG_ERRORS=$(docker exec orfs-agent bash -c "grep -i '^Error\|^ERROR\|\[ERROR\]' \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/5_1_fastroute.log \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/5_2_TritonRoute.log \
  2>/dev/null | head -20" 2>/dev/null || true)
if [ -n "$LOG_ERRORS" ]; then
  MSG="[布线验证失败] 布线日志中发现错误：
${LOG_ERRORS}
请修复上述错误后重新运行布线。"
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

# 检查 DRC 违规数量（必须为 0）
DRC_COUNT=$(docker exec orfs-agent bash -c "grep -i 'violation\|DRC' \
  ${FLOW_DIR}/reports/${PLATFORM}/${DESIGN}/5_route_drc.rpt 2>/dev/null | \
  grep -oE '[0-9]+' | tail -1" 2>/dev/null || echo "")

if [ -n "$DRC_COUNT" ] && [ "$DRC_COUNT" -gt 0 ]; then
  DRC_DETAIL=$(docker exec orfs-agent bash -c "head -50 \
    ${FLOW_DIR}/reports/${PLATFORM}/${DESIGN}/5_route_drc.rpt 2>/dev/null" 2>/dev/null || true)
  MSG="[布线验证失败] 检测到 ${DRC_COUNT} 个 DRC 违规，必须修复后才能继续：
${DRC_DETAIL}
请分析违规类型，调整布线参数或约束后重新布线。"
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

# 检查未连接网络数（open nets）
OPEN_NETS=$(docker exec orfs-agent bash -c "grep -i 'open net\|unconnected' \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/5_2_TritonRoute.log 2>/dev/null | \
  grep -oE '[0-9]+' | head -1" 2>/dev/null || echo "0")
if [ -n "$OPEN_NETS" ] && [ "$OPEN_NETS" -gt 0 ]; then
  MSG="[布线验证失败] 检测到 ${OPEN_NETS} 个未连接网络（open nets），布线不完整。请检查约束和布线参数。"
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

echo "[validate_route] 布线验证通过：DEF 已生成，DRC 违规为 0，无未连接网络。" >&2
jq -n '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "布线验证通过：DEF 已生成，DRC 违规为 0，无未连接网络。"
  }
}'
