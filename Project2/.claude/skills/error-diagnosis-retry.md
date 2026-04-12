---
name: error-diagnosis-retry
description: 当后端流程某阶段失败时，自动分析日志，诊断错误类型，并根据错误类型实施参数级重试策略。
---

# 错误诊断与重试 Skill

## 触发条件
当 `run_orfs_stage` 返回失败，或 `get_report` 指标超出阈值时，自动调用本Skill。

## 诊断流程

### 1. 捕获错误日志
从 `run_orfs_stage` 返回的 `stderr` 或ORFS日志文件中提取最后200行。日志路径：容器内 `/OpenROAD-flow-scripts/flow/logs/sky130hd/<DESIGN_NAME>/base/<stage>.log`。

### 2. 错误分类
根据关键词将错误归类：

| 错误类型 | 关键词 | 可能原因 | 重试策略 |
|---------|--------|----------|----------|
| **时序违例 (Timing Violation)** | `wns`, `tns`, `setup violation`, `hold violation` | 时钟周期过紧，或布局密度过高 | 调整 `CLOCK_PERIOD` (增加10%)，或降低 `CORE_UTILIZATION` (减少5%)，重跑 `place` 及之后阶段 |
| **拥塞 (Congestion)** | `congestion`, `overflow`, `routing congestion` | 单元摆放过密 | 降低 `CORE_UTILIZATION` (减少5~10%)，或提高 `PLACE_DENSITY` 的 `max_density` 值，重跑 `floorplan` + `place` |
| **DRC违例 (DRC Violation)** | `DRC`, `spacing`, `minimum area`, `antenna` | 布线策略或天线效应 | 启用 `ROUTING_ANTENNA` 选项，或调整 `ROUTING_LAYER_ADJUSTMENT`，重跑 `route` |
| **库/文件缺失** | `can't open`, `no such file`, `missing`, `LEF` | 平台文件路径错误或PDK不完整 | 检查镜像完整性，提示用户重新拉取 `openroad/orfs:latest` |
| **综合逻辑错误** | `syntax error`, `undeclared`, `multiple drivers` | RTL代码错误 | 停止流程，报告具体错误行，建议修改RTL |
| **内存不足** | `out of memory`, `killed` | 设计过大或WSL2内存限制 | 增加WSL2内存（`.wslconfig`），或降低 `CORE_UTILIZATION` 减小设计规模 |

### 3. 参数调整映射
根据错误类型，修改 `config.mk` 中对应变量。修改前备份原文件。

| 错误类型 | 修改变量 | 修改方式 | 重试范围 |
|---------|----------|----------|----------|
| 时序违例 | `CLOCK_PERIOD` | 原值 × 1.1 | 从 `place` 开始重跑 |
| 拥塞 | `CORE_UTILIZATION` | 原值 × 0.9 | 从 `floorplan` 开始重跑 |
| DRC违例 | `ROUTING_ANTENNA` | 设置为 `1` | 重跑 `route` |
| 多类型同时发生 | 优先解决拥塞，再处理时序 | 先降利用率，再调时钟 | 先 `floorplan` 后 `place` |

### 4. 重试执行
- 最多重试 **2 次**。
- 每次重试前，将新参数写入 `config.mk`，并清除该阶段及后续阶段的输出（`rm -rf results/sky130hd/<DESIGN_NAME>/base/*`）。
- 重新调用 `run_orfs_stage` 从受影响的最早阶段开始（例如调整利用率需要重跑 `floorplan`）。
- 若2次重试后仍失败，停止流程并向用户输出详细的诊断报告，包括：错误类型、尝试的参数、每次的结果变化、建议的手动干预措施。

## 输出格式
**报告应包含：**

【错误诊断】

- 失败阶段: place

- 错误类型: 拥塞 (congestion)

- 关键日志: [粘贴最后10行相关日志]

- 尝试重试1: 降低 CORE_UTILIZATION 从 40 到 35，重新 floorplan+place → 拥塞仍为 12% (未通过)

- 尝试重试2: 进一步降低到 30 → 拥塞 8% (通过)

- 最终状态: 成功，进入下一阶段



**若最终失败，给出：**

【无法自动修复】

- 建议手动检查 RTL 面积或调整初始利用率。

- 相关日志已保存至 ./logs/place_error.log
