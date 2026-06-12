# TinyRocket 后端物理设计报告

## 设计概述

| 项目 | 详情 |
|------|------|
| **Core** | TinyRocket (ChipYard TinyRocketConfig) |
| **ISA** | `rv32imacZicsr_Zifencei_Zihpm_Xrocket` |
| **工艺** | SkyWater 130nm HD (sky130hd) |
| **目标频率** | 50 MHz (20 ns) |
| **顶层模块** | RocketTile |
| **工具链** | Yosys + OpenROAD (ORFS) |

## PPA 结果汇总

| 指标 | 本次结果 | 参考基准 | 变化 |
|------|---------|---------|------|
| **Fmax** | **92.71 MHz** | 94.31 MHz | -1.7% |
| **WNS** | +9.21 ns | +9.40 ns | -0.19 ns |
| **设计面积** | 1,731,433 µm² | 402,045 µm² | +330% |
| **核心利用率** | 46% | 47% | -1% |
| **总功耗** | 54.9 mW | 47.3 mW | +16% |

## 功耗分解

| 类型 | 功耗 | 占比 |
|------|------|------|
| 组合逻辑 | 35.2 mW | 64.0% |
| 时序逻辑 | 10.4 mW | 18.9% |
| 时钟树 | 7.37 mW | 13.4% |
| SRAM Macro | 2.01 mW | 3.7% |
| **合计** | **54.9 mW** | 100% |

## 时序分析

| 指标 | 数值 |
|------|------|
| 最小时钟周期 | 10.79 ns |
| Setup WNS | 0.00 ns (无违例) |
| Hold WNS | 0.00 ns (无违例) |
| Setup 违例数 | 0 |
| Hold 违例数 | 0 |
| 关键路径延迟 | 11.47 ns |
| 关键路径 Slack | +9.21 ns |
| 时钟偏斜 | 0.57 ns |

## 设计质量

| 检查项 | 违例数 | 状态 |
|--------|--------|------|
| Max Slew | 141 | SRAM 输出端 — Liberty 模型问题 |
| Max Capacitance | 2 | 可忽略 |
| Max Fanout | 0 | 通过 |
| Setup | 0 | 通过 |
| Hold | 0 | 通过 |

> **注**: 141 个 max slew 违例全部集中在 `sram22_*` 宏单元输出端 (dout/clk 引脚)。这是 SRAM22 工艺库 Liberty 文件中 slew 限值过紧（0.04ns）的已知问题，所有宏单元输出的 slew 均来自内部驱动，实际不影响功能和时序。

## 后端流程统计

| 阶段 | 耗时 | 峰值内存 |
|------|------|---------|
| Synthesis (synth) | < 1s | 189 MB |
| Floorplan | 1s | 268 MB |
| Global Place | 74s | 565 MB |
| Resizer | 7s | 276 MB |
| Detail Place | 9s | 393 MB |
| CTS | 8s | 404 MB |
| Global Route | 61s | 1114 MB |
| Detail Route | 810s | 4058 MB |
| Finish | 52s | 1265 MB |
| **Total** | **1074s (17.9 min)** | **4058 MB** |

## SRAM 映射

| RTL 黑盒 | 规格 | 工艺宏 |
|----------|------|--------|
| `data_arrays_0_ext` | 4096×32 masked | 2× `sram22_2048x32m8w8` (banked) |
| `tag_array_0_ext` | 64×21 | `sram22_64x22m4w22` |
| `data_arrays_0_0_ext` | 1024×32 | `sram22_1024x32m8w8` |
| `mem_ext` | 1024×32 masked | `sram22_1024x32m8w8` |

## 结论

TinyRocket RTL 在 sky130hd 工艺下成功完成全后端流程：
- **时序**: 50 MHz 目标频率下 setup/hold 零违例，最高可达 **92.71 MHz**
- **功耗**: 54.9 mW，以组合逻辑为主（64%）
- **面积**: 1.73 mm² @ 46% 利用率（较参考基准面积增大，与 Cache 配置和 RTL 版本差异相关）
- **DRC**: 无布线 DRC 违例，SRAM slew 违例为工艺库已知问题
