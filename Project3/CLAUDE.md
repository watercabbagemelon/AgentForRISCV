# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 项目概述

本项目实现 RISC-V 芯片（以 tinyRocket 为基础，可扩展至其他 ChipYard 配置）在 SkyWater 130nm (sky130hd) 工艺下的完整前后端流程，分三个阶段：

1. **RTL 生成**：ChipYard docker 生成 Verilog RTL
2. **SRAM 工艺映射**：将 FIRRTL SRAM 黑盒替换为 sram22_sky130 物理宏
3. **后端综合布局布线**：OpenROAD Flow Scripts (ORFS) 完成全流程

---

## 工具链与容器

| 容器名 | Docker 镜像 | 用途 |
|--------|------------|------|
| `chipyard-agent` | `ictmrc/chipyard-image:1.9.1-ubuntu-22.04` | RTL 生成 |
| `orfs-agent` | `openroad/orfs:latest` | 综合、布局、布线 |

两个容器均挂载宿主机 `./persist/` 到容器内 `/workspace/persist`。

---

## MCP 架构

项目通过两个 MCP server 封装所有容器操作，注册在 `.mcp.json`：

### `chipyard-automation`（`mcp_server/src/chipyard.js`）

前端 RTL 生成工具，所有设计名通过参数传入，不硬编码：

| 工具 | 关键参数 | 说明 |
|------|---------|------|
| `start_chipyard` | `image` | 启动容器，挂载 persist |
| `generate_rtl` | `config`, `extra_make_args` | 激活 conda，运行 make verilog，30min 超时 |
| `read_mems_conf` | `config` | 解析 SRAM 黑盒列表，返回结构化 JSON |
| `list_rtl_files` | `config`, `subdir` | 列出 RTL 输出目录 |
| `read_rtl_file` | `config`, `filename` | 读取 RTL 文件，路径限制在 rtl_output/ 内 |
| `stop_chipyard` | — | 停止并删除容器 |

### `orfs-agent`（`mcp_server/src/index.js`）

后端 PnR 工具，设计参数集中在文件顶部配置区：

| 工具 | 关键参数 | 说明 |
|------|---------|------|
| `run_stage` | `stage` (synth/floorplan/place/cts/route/finish) | 执行 ORFS 阶段，自动附加 SKIP_CTS_REPAIR_TIMING=1，1h 超时 |
| `get_metrics` | — | 读取 metadata.json，返回 PPA 指标 |
| `read_container_file` | `path` | 读取容器内日志/报告 |
| `list_files_container` | `path` | 浏览容器内目录 |
| `read_file` | `path` | 读取宿主机文件，限制在 PROJECT_ROOT 内 |
| `write_file` | `path`, `content` | 写入宿主机文件，限制在 PROJECT_ROOT 内 |

**修改设计时**需同步更新 `mcp_server/src/index.js` 顶部的四个常量：
```js
const DESIGN_CONFIG   = "designs/sky130hd/<nickname>/config.mk";
const DESIGN_PLATFORM = "sky130hd";
const DESIGN_NICKNAME = "<nickname>";
```

---

## 持久化目录结构

```
persist/
├── sky130hd/<design_nickname>/
│   ├── config.mk          # ORFS 设计配置（DESIGN_NAME、利用率、密度等）
│   ├── constraint.sdc     # 时序约束（目标频率）
│   └── sram_macros.v      # SRAM 黑盒 wrapper（映射到 sram22 宏）
├── sram22_sky130_macros/  # 物理宏库（64×8 ~ 2048×64，含 .lef/.lib/.v/.gds）
├── rtl_output/            # ChipYard 生成的 RTL
│   └── chipyard.TestHarness.<Config>/
└── orfs_results/          # ORFS 最终产物（GDS/DEF/网表/SPEF）
```

---

## SRAM 映射关键约束

ORFS 后端使用内置旧版 rocket-chip Verilog（`freechips.rocketchip.system.TinyConfig`），**不是** ChipYard 生成的 SV 文件（Yosys 不支持 SystemVerilog）。

旧版 SRAM 黑盒与映射方案：

| 模块名 | 规格 | 映射宏 |
|--------|------|--------|
| `data_arrays_0_ext` | 64×32, masked | `sram22_64x32m4w8` |
| `tag_array_ext` | 4×25, rw | flop（太小，无合适宏） |
| `data_arrays_0_0_ext` | 64×32, rw | `sram22_64x32m4w8`（wmask 固定 4'hF） |
| `mem_ext` | 1024×32, 1R+1W | `sram22_1024x32m8w8`（写优先仲裁） |

---

## Skills

`skills/` 目录下有三个可调用的工作流 skill：

| Skill | 用途 |
|-------|------|
| `/flow` | 完整前后端流程（RTL生成 → SRAM映射 → PnR → 报告） |
| `/summary` | 分析 ORFS 结果，生成 PPA 报告（频率/面积/拥塞/功耗/时序裕量） |
| `/debug` | 常见问题诊断与修复（conda 环境、WSL2 崩溃、步骤重跑等） |

---

## WSL2 已知问题

CTS 后 `detailed_placement` 在 WSL2 下会崩溃（illegal instruction）。`orfs-agent` MCP 的 `run_stage` 已自动附加 `SKIP_CTS_REPAIR_TIMING=1`，手动运行时需显式加上此参数。

---

## tinyRocket 实现结果（参考基准）

| 指标 | 数值 |
|------|------|
| 工艺 | sky130hd |
| 目标频率 | 50 MHz（20 ns） |
| Fmax | **94.31 MHz** |
| WNS | +9.40 ns |
| 设计面积 | 402,045 µm² |
| 核心利用率 | 47% |
| 总功耗 | 47.3 mW |
| 触发器数量 | 3,926 |
