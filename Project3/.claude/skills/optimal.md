# optimal

后端流程 Bug 修复与 PPA 参数优化指南。分两部分：
- **Part A**：流程 Bug 诊断与修复（流程无法跑通时）
- **Part B**：PPA 参数调优（流程跑通但结果不满足指标时）

## Usage

```
/optimal [问题描述]
```

- `问题描述` (optional): 如 "synth 报错"、"时序违例"、"拥塞严重" 等

---

# Part A：后端流程 Bug 修复

## A1. 综合阶段（synth）失败

### 症状：Yosys 报 "ERROR: Module not found"

**原因：** RTL 源文件缺失或顶层模块名与 `config.mk` 中 `DESIGN_NAME` 不一致。

**排查：**
```
read_file("persist/sky130hd/<design_nickname>/config.mk")
```
确认 `DESIGN_NAME` 与 RTL 顶层模块名完全一致。

**修复：** 更新 `config.mk` 中的 `DESIGN_NAME`，或检查 `VERILOG_FILES` 路径是否正确。

---

### 症状：Yosys 报 "ERROR: syntax error" 或 "unsupported SystemVerilog"

**原因：** Yosys 对 SystemVerilog 支持有限，ChipYard 生成的 `.sv` 文件无法直接综合。

**修复：** 使用 ORFS 内置的旧版 rocket-chip Verilog 源，而非 ChipYard 生成的 SV 文件。
确认 `config.mk` 中 `VERILOG_FILES` 指向 `.v` 文件而非 `.sv`。

---

### 症状：综合后面积异常偏大（标准单元数量 >> 预期）

**原因：** SRAM 黑盒未被正确识别，被综合成了寄存器堆。

**排查：**
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/1_1_yosys.log")
```
搜索 `data_arrays`、`mem_ext` 等模块名，确认是否出现 `inferred memory` 警告。

**修复：** 检查 `sram_macros.v` 中的 wrapper 模块名是否与 RTL 中的黑盒实例名完全匹配，
并确认 `config.mk` 中 `VERILOG_FILES` 包含了 `sram_macros.v`。

---

## A2. 布图规划阶段（floorplan）失败

### 症状：宏摆放失败 "Cannot place macro"

**原因：** 核心面积太小，无法容纳所有宏单元。

**排查：**
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/2_1_floorplan.log")
```

**修复：** 降低 `CORE_UTILIZATION` 或增大 `CORE_MARGIN`：
```makefile
export CORE_UTILIZATION = 35   # 从 45 降低
export CORE_MARGIN      = 4    # 从 2 增大
```

---

### 症状：LEF 文件找不到 "Cannot open LEF file"

**原因：** `ADDITIONAL_LEFS` 路径错误，或宏库文件未挂载到容器。

**修复：** 确认路径以 `/workspace/persist/` 开头，且宏目录存在：
```
list_files_container("/workspace/persist/sram22_sky130_macros/")
```

---

## A3. 布局阶段（place）失败

### 症状：overflow 不收敛，布局无法完成

**原因：** 布局密度过高，标准单元无法合法摆放。

**修复：** 降低布局密度：
```makefile
export PLACE_DENSITY   = 0.50   # 从 0.60 降低
export CORE_UTILIZATION = 40    # 同步降低
```

---

### 症状：WSL2 下 detailed_placement 崩溃（illegal instruction）

**原因：** WSL2 内核不支持某些 SIMD 指令。

**修复：** `orfs-agent` MCP 的 `run_stage` 已自动附加 `SKIP_CTS_REPAIR_TIMING=1`，
手动运行时需显式加上：
```bash
make DESIGN_CONFIG=... SKIP_CTS_REPAIR_TIMING=1 place
```

---

## A4. 布线阶段（route）失败

### 症状：布线后存在 DRC violations

**原因：** 布局拥塞导致布线无法合法完成。

**排查：**
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/5_2_route.log")
```
搜索 `violation` 关键字，定位拥塞层和区域。

**修复策略（按严重程度递进）：**

1. 降低布局密度：`PLACE_DENSITY = 0.50 → 0.45`
2. 调整宏摆放位置（在 floorplan 阶段手动指定宏坐标）
3. 增大核心面积：降低 `CORE_UTILIZATION`

---

## A5. 重跑某个步骤

删除对应结果文件后重跑，通过 `run_stage` MCP 执行：

| 步骤 | 需删除的文件前缀 |
|------|----------------|
| synth | `results/.../1_*.v` |
| floorplan | `results/.../2_*.odb` |
| place | `results/.../3_*.odb` |
| cts | `results/.../4_*.odb` |
| route | `results/.../5_*.odb` |
| finish | `results/.../6_final.*` |

```
run_stage(stage="<step>")
```

---

# Part B：PPA 参数调优

## B1. 时序优化

### 场景：存在时序违例（WNS < 0）

**诊断：**
```
get_metrics()   # 查看 finish__timing__setup__ws
read_container_file(".../6_finish.rpt")  # 查看关键路径
```

**调优策略（按优先级）：**

| 策略 | 修改项 | 说明 |
|------|--------|------|
| 降低目标频率 | `constraint.sdc` 时钟周期 +2~5 ns | 最直接，牺牲性能换时序收敛 |
| 降低布局密度 | `PLACE_DENSITY` -0.05 | 给布线留更多空间，减少绕线延迟 |
| 开启时序驱动布局 | `PLACE_DENSITY` 不变，检查 `GPL_TIMING_DRIVEN` | 默认已开启 |
| 增加时序裕量 | `CORE_UTILIZATION` -5% | 降低拥塞，改善时序路径 |

**修改 constraint.sdc（降频示例）：**
```tcl
# 原：50 MHz（20 ns）→ 改为 40 MHz（25 ns）
create_clock [get_ports clk] -name core_clk -period 25.0
```

---

### 场景：WNS 裕量充足（> 3 ns），希望提频

**调优策略：**

| 目标 Fmax | 建议时钟周期 | 风险 |
|-----------|------------|------|
| 60 MHz | 16.7 ns | 低 |
| 75 MHz | 13.3 ns | 中 |
| 100 MHz | 10.0 ns | 高，需降低密度配合 |

提频时建议同步降低 `PLACE_DENSITY`（-0.05）以给时序修复留余量。

---

## B2. 面积优化

### 场景：面积偏大，希望缩小芯片

**调优策略：**

| 策略 | 修改项 | 预期效果 |
|------|--------|---------|
| 提高利用率 | `CORE_UTILIZATION` +5~10% | 直接缩小核心面积，但拥塞风险上升 |
| 提高布局密度 | `PLACE_DENSITY` +0.05 | 单元排列更紧密 |
| 开启面积优化综合 | `SYNTH_STRATEGY = AREA 0` | 综合时优先面积，可能牺牲时序 |
| 移除冗余缓冲器 | `REMOVE_ABC_BUFFERS = 1`（已默认） | 减少综合插入的多余 buffer |

**注意：** `CORE_UTILIZATION > 70%` 时拥塞风险显著上升，建议不超过 65%。

---

## B3. 拥塞优化

### 场景：布局 overflow > 0.1 或布线 DRC > 0

**调优策略（按优先级）：**

| 策略 | 修改项 | 说明 |
|------|--------|------|
| 降低布局密度 | `PLACE_DENSITY` 0.60 → 0.50 | 最有效，首选 |
| 降低核心利用率 | `CORE_UTILIZATION` -5~10% | 扩大核心面积 |
| 调整长宽比 | `CORE_ASPECT_RATIO` 1 → 1.5 | 改变芯片形状，有时能缓解局部拥塞 |
| 增大核心边距 | `CORE_MARGIN` 2 → 4 | 给 IO 和边缘布线留更多空间 |

**config.mk 拥塞优化示例：**
```makefile
export CORE_UTILIZATION  = 40    # 降低
export CORE_ASPECT_RATIO = 1.2   # 略微拉长
export CORE_MARGIN       = 3
export PLACE_DENSITY     = 0.50  # 降低
```

---

## B4. 功耗优化

### 场景：总功耗偏高

**诊断：** 区分动态功耗与漏电功耗的占比：
```
get_metrics()
# 查看 finish__power__internal__total / switching / leakage
```

**调优策略：**

| 功耗类型 | 策略 | 修改项 |
|---------|------|--------|
| 动态功耗偏高 | 检查时钟门控覆盖率 | 确认 RTL 中 clock gating 已实现 |
| 动态功耗偏高 | 降低工作频率 | `constraint.sdc` 时钟周期增大 |
| 漏电功耗偏高 | 使用高阈值电压单元 | sky130hd 工艺下调整综合约束 |
| 整体偏高 | 降低布局密度 | 减少不必要的时序修复 buffer |

---

## B5. 参数调优速查表

| 优化目标 | 关键参数 | 调整方向 | 副作用 |
|---------|---------|---------|--------|
| 提高 Fmax | `constraint.sdc` 周期 | 减小 | 可能引入时序违例 |
| 降低 Fmax（修复违例） | `constraint.sdc` 周期 | 增大 | 性能下降 |
| 缩小面积 | `CORE_UTILIZATION` | 增大 | 拥塞风险上升 |
| 缓解拥塞 | `PLACE_DENSITY` | 减小 | 面积增大 |
| 缓解拥塞 | `CORE_UTILIZATION` | 减小 | 面积增大 |
| 改变芯片形状 | `CORE_ASPECT_RATIO` | 调整 | 影响宏摆放 |
| 扩大边缘空间 | `CORE_MARGIN` | 增大 | 面积略增 |

---

## B6. 典型优化迭代路径

```
初始跑通
  │
  ├─ 时序违例？ → 降频 or 降密度 → 重跑 place+cts+route+finish
  │
  ├─ 拥塞/DRC？ → 降 PLACE_DENSITY → 重跑 place+route+finish
  │
  ├─ 面积过大？ → 提高 CORE_UTILIZATION → 重跑 floorplan+place+...
  │
  └─ 满足指标 → /report 生成报告
```

每次参数修改后，使用 `/report` 记录优化前后的 PPA 变化。

---

## 参考

- 流程操作 → `/flow`
- 结果报告 → `/report`
- PPA 分析 → `/summary`
- 环境 Bug → `/debug`
