#!/usr/bin/env bash
# 版图生成阶段验证：检查 GDS 文件是否生成且有效
set -euo pipefail

FLOW_DIR="/OpenROAD-flow-scripts/flow"
DESIGN="ALU"
PLATFORM="sky130hd"
RESULTS_DIR="${FLOW_DIR}/results/${PLATFORM}/${DESIGN}"
HOST_RESULTS="results"

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

if ! echo "$CMD" | grep -qE '6_finish|make.*DESIGN_CONFIG'; then
  exit 0
fi

echo "[validate_finish] 开始验证版图生成阶段产物..." >&2

# 检查容器内 GDS 文件
GDS_FILE=$(docker exec orfs-agent bash -c "ls ${RESULTS_DIR}/6_final.gds 2>/dev/null" 2>/dev/null || true)
if [ -z "$GDS_FILE" ]; then
  MSG="[版图验证失败] 未找到 GDS 文件（${RESULTS_DIR}/6_final.gds）。版图生成阶段可能未完成，请检查 finish 日志。"
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

# 检查 GDS 文件大小（不应为空）
GDS_SIZE=$(docker exec orfs-agent bash -c "stat -c%s ${RESULTS_DIR}/6_final.gds 2>/dev/null || echo 0" 2>/dev/null || echo "0")
if [ "$GDS_SIZE" -lt 1024 ]; then
  MSG="[版图验证失败] GDS 文件过小（${GDS_SIZE} bytes），可能为空文件或生成不完整。请重新运行 6_finish 阶段。"
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

# 检查 finish 日志中的错误
LOG_ERRORS=$(docker exec orfs-agent bash -c "grep -i '^Error\|^ERROR\|\[ERROR\]' \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/6_1_fill.log \
  ${FLOW_DIR}/logs/${PLATFORM}/${DESIGN}/6_1_merge.log \
  2>/dev/null | head -20" 2>/dev/null || true)
if [ -n "$LOG_ERRORS" ]; then
  MSG="[版图验证失败] finish 日志中发现错误：
${LOG_ERRORS}
请修复上述错误后重新运行版图生成。"
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

# 检查宿主机 results/ 目录中的 GDS（是否已复制）
if [ ! -f "${HOST_RESULTS}/6_final.gds" ]; then
  echo "[validate_finish] 警告：宿主机 results/6_final.gds 不存在，尝试从容器复制..." >&2
  docker cp "orfs-agent:${RESULTS_DIR}/6_final.gds" "${HOST_RESULTS}/6_final.gds" 2>/dev/null || true
fi

# 验证 GDS 文件头（GDS 二进制格式以 \x00\x06\x00\x02 开头）
GDS_MAGIC=$(docker exec orfs-agent bash -c "xxd -l 4 ${RESULTS_DIR}/6_final.gds 2>/dev/null | head -1" 2>/dev/null || true)
if ! echo "$GDS_MAGIC" | grep -qiE '0006|gds'; then
  # 也接受 OASIS 格式（%SEMI）
  GDS_HEAD=$(docker exec orfs-agent bash -c "head -c 8 ${RESULTS_DIR}/6_final.gds 2>/dev/null | strings" 2>/dev/null || true)
  if ! echo "$GDS_HEAD" | grep -qiE 'SEMI|OASIS|GDS'; then
    echo "[validate_finish] 警告：无法验证 GDS 文件格式头，但文件大小正常（${GDS_SIZE} bytes）。" >&2
  fi
fi

echo "[validate_finish] 版图验证通过：GDS 文件已生成（${GDS_SIZE} bytes），无错误。" >&2
jq -n --arg size "$GDS_SIZE" '{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": ("版图验证通过：GDS 文件已生成（" + $size + " bytes），无错误。")
  }
}'
