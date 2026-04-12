---
name: backend-flow
description: 执行从RTL到GDSII的完整后端自动化流程，包括综合、布局规划、布局、时钟树综合、布线、收尾，每阶段检查指标并决策下一步。
---

# 后端自动化流程编排 Skill

## 触发条件
用户明确要求运行后端流程，例如：“运行ALU的后端流程”、“开始后端自动化”、“执行ORFS全流程”。

## 前置条件
- 常驻容器 `orfs-agent` 已运行（如未运行，提示用户执行 `docker start orfs-agent`）。
- 本地 `./design/` 目录包含：
  - `rtl/` 下的Verilog文件（顶层模块名与 `config.mk` 中一致）
  - `config.mk` 配置文件
  - `constraint.sdc` 时序约束文件
- 已配置MCP Server且工具可用（`run_orfs_stage`, `get_report` 等）。

## 流程定义

按照以下顺序依次执行各阶段。每个阶段完成后，调用 `get_report` 提取关键指标，并根据预定义阈值决定继续、重试或上报用户。

### 阶段顺序与目标
| 阶段 | make target | 成功标准 | 可选重试参数 |
|------|-------------|----------|--------------|
| 1. 综合 (synthesis) | `synth` | 无致命错误，面积 < 50000 um^2（可根据实际调整） | 无（若失败，报告RTL问题） |
| 2. 布局规划 (floorplan) | `floorplan` | 核心利用率 ≤ 设定值（默认45%），无溢出 | 降低 `CORE_UTILIZATION` 重试 |
| 3. 布局 (placement) | `place` | 拥塞 < 15%，无严重时序违例（WNS > -0.5ns） | 调整 `PLACE_DENSITY` 或 `CORE_UTILIZATION` |
| 4. 时钟树综合 (cts) | `cts` | 时钟偏斜 < 0.1ns，WNS无明显恶化 | 调整时钟树配置（如缓冲器类型） |
| 5. 布线 (route) | `route` | DRC违例数 = 0，WNS ≥ -0.2ns | 开启更激进的布线策略或调整布线层 |
| 6. 收尾 (finish) | `finish` | 生成最终GDS和报告 | 无需重试 |

### 决策规则
- **成功**：指标满足成功标准 → 进入下一阶段。
- **可重试**：指标不达标但可通过调整参数改善（见上表“可选重试参数”）→ 修改 `config.mk` 中对应变量，重新执行当前阶段（最多重试2次）。每次重试后重新评估。
- **致命失败**：工具崩溃、文件缺失、综合逻辑错误 → 停止流程，向用户报告错误类型并建议手动检查。

### 每阶段检查项（调用 `get_report`）
- 综合后：`area`（设计面积）、`cell_count`
- 布局规划后：`core_area`、`utilization`
- 布局后：`congestion`（拥塞百分比）、`wns`（最差负时序裕量）
- 时钟树后：`skew`、`wns`
- 布线后：`drc_violations`、`wns`、`tns`
- 收尾后：确认 `6_final.gds` 存在

## 最终报告输出
流程结束后（无论成功或失败），生成汇总报告，包含：
- 各阶段状态（✅/⚠️/❌）
- PPA表格：阶段名称，面积(um²)，WNS(ns)，TNS(ns)，DRC违例数，拥塞(%)
- 关键日志摘要（如最差时序路径、DRC违规类型）
- 若使用了重试，记录每次尝试的参数和结果变化
- 最终版图文件路径（容器内 `/OpenROAD-flow-scripts/flow/results/sky130hd/<DESIGN_NAME>/base/6_final.gds`，宿主机对应挂载位置）

报告保存至 `./reports/backend_summary.md`，并直接输出到对话中。

## 使用示例
用户：“运行ALU的后端流程”
Agent：
1. 检查前置条件（容器、文件）。
2. 调用 `run_orfs_stage synth`。
3. 调用 `get_report synth area` → 面积 OK → 继续。
4. 调用 `run_orfs_stage floorplan` → 利用率 43% → OK → 继续。
5. ... 直至 finish。
6. 生成报告并展示。