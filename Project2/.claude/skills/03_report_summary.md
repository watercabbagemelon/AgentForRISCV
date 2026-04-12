# Skill: 读取各阶段报告并总结

## 概述

本 skill 描述如何读取 OpenROAD flow 各阶段生成的报告，提取关键指标，并给出综合评估。

---

## 快速总览命令

```bash
# 进入容器
docker exec -it orfs-agent bash
cd /OpenROAD-flow-scripts/flow

DESIGN=sky130hd/alu/base   # 修改此变量适配不同设计

# 一键打印所有关键指标
echo "=== 综合报告 ===" && grep -E "Chip area|Number of cells|Utilization" logs/$DESIGN/1_synth.log | tail -5
echo "=== 布局利用率 ===" && grep -i "utilization" logs/$DESIGN/3_place.log | tail -3
echo "=== 布线 DRC ===" && grep -E "violation|DRC" logs/$DESIGN/5_route.log | tail -5
echo "=== 最终报告 ===" && cat results/$DESIGN/6_final_report.rpt
```

---

## 阶段 1：综合报告

```bash
cat logs/sky130hd/alu/base/1_synth.log | grep -A5 "Chip area"
```

**关键指标**：
| 指标 | 含义 | 理想范围 |
|------|------|---------|
| `Chip area` | 综合后估算面积（μm²） | 越小越好 |
| `Number of cells` | 标准单元数量 | — |
| `Utilization` | 综合利用率估算 | < 80% |
| `WNS`（Worst Negative Slack） | 最差时序裕量 | ≥ 0 表示时序满足 |
| `TNS`（Total Negative Slack） | 总负裕量 | 0 为最优 |

```bash
# 查看综合后网表单元统计
grep -E "^\s+\$" results/sky130hd/alu/base/1_synth.v | sort | uniq -c | sort -rn | head -20
```

---

## 阶段 2：布图规划报告

```bash
grep -E "Core area|Die area|Aspect ratio" logs/sky130hd/alu/base/2_floorplan.log
```

**关键指标**：
| 指标 | 含义 |
|------|------|
| `Die area` | 芯片总面积（含 IO ring） |
| `Core area` | 核心逻辑区域面积 |
| `Aspect ratio` | 长宽比（1.0 = 正方形） |

---

## 阶段 3：布局报告

```bash
grep -E "utilization|overflow|HPWL" logs/sky130hd/alu/base/3_place.log | tail -10
```

**关键指标**：
| 指标 | 含义 | 警戒线 |
|------|------|--------|
| `Utilization` | 布局后实际利用率 | < 75% |
| `Overflow` | 布局溢出率 | < 1% |
| `HPWL` | 半周长线长（布线难度估算） | 越小越好 |

```bash
# 查看布局后时序
grep -E "WNS|TNS|Setup" logs/sky130hd/alu/base/3_place.log | tail -5
```

---

## 阶段 4：时钟树综合报告

```bash
cat logs/sky130hd/alu/base/4_cts.log | grep -E "Clock|Skew|Latency|Buffer"
```

**关键指标**（仅适用于时序设计）：
| 指标 | 含义 | 理想范围 |
|------|------|---------|
| `Clock skew` | 时钟偏斜 | < 10% 时钟周期 |
| `Max latency` | 最大时钟延迟 | 越小越好 |
| `Buffer count` | 插入的时钟 buffer 数 | — |

> 纯组合逻辑设计跳过此阶段，无报告。

---

## 阶段 5：布线报告

```bash
# DRC 违规统计
grep -E "violation|DRC|Short|Spacing" logs/sky130hd/alu/base/5_route.log | tail -10

# 布线后时序
grep -E "WNS|TNS|Setup|Hold" logs/sky130hd/alu/base/5_route.log | tail -10
```

**关键指标**：
| 指标 | 含义 | 目标 |
|------|------|------|
| `DRC violations` | 设计规则违规数 | 0 |
| `WNS`（布线后） | 最差时序裕量 | ≥ 0 |
| `Routing iterations` | 详细布线迭代次数 | 越少越好 |

---

## 阶段 6：最终综合报告

```bash
cat results/sky130hd/alu/base/6_final_report.rpt
```

报告包含以下部分：

### 时序报告（Timing）
```
# 查看最差路径
grep -A 20 "Startpoint" results/sky130hd/alu/base/6_final_report.rpt | head -30
```

| 字段 | 含义 |
|------|------|
| `data arrival time` | 数据到达时间 |
| `data required time` | 数据需求时间 |
| `slack` | 裕量（负值 = 违规） |

### 功耗报告（Power）
```bash
grep -A 10 "Power" results/sky130hd/alu/base/6_final_report.rpt
```

| 字段 | 含义 |
|------|------|
| `Internal power` | 内部翻转功耗 |
| `Switching power` | 开关功耗 |
| `Leakage power` | 静态漏电功耗 |
| `Total power` | 总功耗（mW） |

### IR Drop 报告
```bash
grep -E "max IR|avg IR|voltage" results/sky130hd/alu/base/6_final_report.rpt
```

---

## 综合评估模板

读取完所有报告后，按以下模板总结：

```
设计名称：___________（平台：sky130hd 130nm）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### PPA 综合评估表

| 维度 | 指标 | 数值 | 目标 / 说明 | 状态 |
|------|------|------|-------------|------|
| **Performance（性能）** | 时钟目标 | _____ ns（_____ MHz） | 设计约束 | — |
| | WNS | _____ ns | ≥ 0 为满足 | □ 满足 / □ 违规 |
| | TNS | _____ ns | 0 为最优 | — |
| | Setup 违规路径数 | _____ 条 | 0 | — |
| | Hold 违规路径数 | _____ 条 | 0 | — |
| | 实际可达频率 | ≈ _____ MHz | period_min 推算 | — |
| | 关键路径延迟 | _____ ns | — | — |
| **Power（功耗）** | 总功耗 | _____ mW | 越小越好 | — |
| | 内部功耗 | _____ mW（_____%) | — | — |
| | 开关功耗 | _____ mW（_____%) | — | — |
| | 静态漏电 | _____ nW | 越小越好 | — |
| **Area（面积）** | 综合面积 | _____ μm² | 越小越好 | — |
| | 实际利用率 | _____% | < 75% | — |
| | 标准单元总数 | _____ 个 | — | — |
| **布线质量** | DRC 违规 | _____ 个 | 0 | □ 干净 / □ 违规 |
| | IR Drop（VDD） | _____ mV（_____%) | < 5% | — |
| | max slew 违规 | _____ 个 | 0 | — |
| | max cap 违规 | _____ 个 | 0 | — |

```
【结论】
  □ 时序满足  □ 时序违规（需放宽约束或优化设计）
  □ DRC 干净  □ DRC 违规（需降低利用率或检查设计）
  □ 信号完整性满足  □ 存在 slew/cap 违规
  备注：___________
```

---

## 本次 ALU 设计实际结果

设计名称：alu（sky130hd 130nm）

### PPA 综合评估表

| 维度 | 指标 | 数值 | 目标 / 说明 | 状态 |
|------|------|------|-------------|------|
| **Performance（性能）** | 时钟目标 | 1.10 ns（909 MHz） | 设计约束 | — |
| | WNS | -2.70 ns | ≥ 0 为满足 | ✗ 违规 |
| | TNS | -68.10 ns | 0 为最优 | — |
| | Setup 违规路径数 | 33 条 | 0 | — |
| | Hold 违规路径数 | 0 条 | 0 | ✓ 满足 |
| | 实际可达频率 | ≈ 263 MHz | period_min = 3.80 ns | — |
| | 关键路径延迟 | 3.58 ns（io_b[0]→io_result[0]） | — | — |
| **Power（功耗）** | 总功耗 | 9.59 mW | 1.8V TT 25°C | — |
| | 内部功耗 | 5.08 mW（53%） | — | — |
| | 开关功耗 | 4.51 mW（47%） | — | — |
| | 静态漏电 | 5.65 nW | 纯组合逻辑，极低 | ✓ 优秀 |
| **Area（面积）** | 综合面积 | 12561 μm² | — | — |
| | 实际利用率 | 64% | < 75% | ✓ 满足 |
| | 标准单元总数 | 3427 个（含 1718 fill、517 buf） | — | — |
| **布线质量** | DRC 违规 | 0 个 | 0 | ✓ 干净 |
| | IR Drop（VDD） | 0.409 mV（0.02%） | < 5% | ✓ 优秀 |
| | max slew 违规 | 0 个 | 0 | ✓ 满足 |
| | max cap 违规 | 0 个 | 0 | ✓ 满足 |

**结论**：
- ✓ DRC 干净，版图可制造
- ✓ 信号完整性全部满足（slew/fanout/cap 无违规）
- ✓ Hold 时序满足，IR drop 极低
- ✗ Setup 时序违规：约束 909 MHz 超出 sky130hd 工艺极限（~263 MHz），差距约 4 倍
- 加法器架构：工具自动选择 Han-Carlson + Brent-Kung + Kogge-Stone 混合架构
- 建议：将 `clk_period` 改为 `4.0`（250 MHz）重跑，可获得时序完全干净的结果
