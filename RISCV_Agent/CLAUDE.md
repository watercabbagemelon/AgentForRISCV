# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

本项目设计了一个自主设计RISCV芯片的Agent，通过chipyard docker生成RTL，Agent自主进行设计空间探索优化，使用OpenROAD docker完成芯片设计后端流程。

---

## 项目概述

本项目实现 RISC-V 芯片，在 SkyWater 130nm (sky130hd) 工艺下的完整前后端流程，分三个阶段：

1. **RTL 生成**：ChipYard docker 生成 Verilog RTL
2. **SRAM 工艺映射**：将 FIRRTL SRAM 黑盒替换为 sram22_sky130 物理宏
3. **后端综合布局布线**：OpenROAD Flow Scripts (ORFS) 完成全流程

---

## 工具链与容器

| 容器名 | Docker 镜像 | 用途 |
|--------|------------|------|
| `chipyard-agent` | `ictmrc/chipyard-image:1.9.1-ubuntu-22.04` | RTL 生成 |
| `orfs-agent` | `openroad/orfs:latest` | 综合、布局、布线 |

**容器挂载关系：**

| 容器 | 宿主机相对路径 | 容器内路径 | 用途 |
|------|---------------|-----------|------|
| `chipyard-agent` | `./vsrc` | `/workspace/vsrc` | RTL 生成输出 |
| `orfs-agent` | `./vsrc` | `/workspace/vsrc` | 读取 RTL（filelist.f） |
| `orfs-agent` | `./tech` | `/workspace/tech` | SRAM 宏库（.lef/.lib/.gds）+ PDK |
| `orfs-agent` | `./sky130hd` | `/workspace/sky130hd` | 设计配置（config.mk、constraint.sdc、sram_macros.v） |
| `orfs-agent` | `./backend` | `/workspace/backend` | 后端流程输出 |

> 设计配置从 `sky130hd/<nickname>/` 挂载到容器内 `/workspace/sky130hd/`，需在 ORFS 启动后部署到 `designs/sky130hd/<nickname>/`。

---

## 目录结构

```
RISCV_Agent/                        # 活跃项目（第三阶段 Agent 串联）
├── vsrc/                           # ChipYard 挂载点
│   ├── rtl_output/                 #   ChipYard 生成的 RTL（62 MB，含 gen-collateral + verilog_synth）
│   │   └── chipyard.TestHarness.<Config>/
│   └── verilog_synth/              #   平坦化的可综合 Verilog 备份（458 .sv 文件）
│
├── sky130hd/                       # 设计配置（每个设计一个子目录）
│   └── <design_nickname>/
│       ├── config.mk               #   ORFS 设计配方（顶层模块、RTL 路径、面积约束）
│       ├── constraint.sdc          #   时序约束（目标时钟周期）
│       └── sram_macros.v           #   SRAM 黑盒→sram22 物理宏 wrapper
│
├── tech/                           # 工艺库
│   ├── sram22_sky130_macros/       #   SRAM22 物理宏库（543 MB，含 .lef/.lib/.v/.gds）
│   └── conda-sky130/              #   sky130hd PDK（conda 安装）
│
├── backend/                        # ORFS 挂载点（后端流程阶段输出）
│   ├── synth/  floorplan/  place/  cts/  route/  final/
│
├── mcp_server/                     # MCP 服务器
│   └── src/
│       ├── chipyard.js             #   chipyard-automation：容器管理 + RTL 生成 + firtool 后处理
│       └── index.js                #   orfs-agent：ORFS 阶段运行 + 文件读写 + PPA 采集
│
├── .claude/
│   ├── settings.local.json         # MCP 权限（允许 docker 命令和 MCP 工具调用）
│   └── skills/                     # 5 个 work skill（flow / summary / report / optimal / debug）
├── .mcp.json                       # MCP server 注册入口
│
├── result/                         # 历史 PPA 报告（旧目录）
├── report/                         # 当前 PPA 报告 + 优化日志（新目录）
│
├── orfs_results/                   # ORFS 完整运行结果参考（sky130hd_tinyRocket）
├── riscv-tests/                    # RISC-V ISA 测试套件（含文档指南）
└── test/                           # 测试辅助
```

> 同级目录 `Project1/`、`Project2/`、`Project3/` 分别为课程第一、二、三阶段的早期版本，当前活跃项目为 `RISCV_Agent/`。

---

## MCP 架构

项目通过两个 MCP server 封装所有容器操作，注册在 `.mcp.json`。

### `chipyard-automation`（`mcp_server/src/chipyard.js`）

所有设计名通过参数传入，不硬编码。配置区常量：`VSRC_DIR`（`./vsrc`）、`RTL_OUTPUT_DIR`（`./vsrc/rtl_output`）。

| 工具 | 关键参数 | 说明 |
|------|---------|------|
| `start_chipyard` | `image` | 启动容器，挂载 `./vsrc:/workspace/vsrc` |
| `generate_rtl` | `config`, `extra_make_args` | 激活 conda，运行 `make verilog`（30min 超时），然后 firtool 后处理生成可综合 Verilog，自动删除 TLMonitor 等验证模块 |
| `read_mems_conf` | `config` | 解析 `*.mems.conf`，返回 SRAM 黑盒列表（名称/深度/宽度/端口类型） |
| `list_rtl_files` | `config`, `subdir` | 列出 `vsrc/rtl_output/<config>/` 下的文件 |
| `read_rtl_file` | `config`, `filename` | 读取 RTL 文件，路径强制限制在 `RTL_OUTPUT_DIR` 内 |
| `stop_chipyard` | — | 停止并删除 chipyard-agent 容器 |

### `orfs-agent`（`mcp_server/src/index.js`）

设计参数集中在文件顶部配置区。**修改设计时**需同步更新四个常量：

```js
const DESIGN_CONFIG   = "designs/sky130hd/<nickname>/config.mk";
const DESIGN_PLATFORM = "sky130hd";
const DESIGN_NICKNAME = "<nickname>";
```

宿主机文件读写（`read_file`/`write_file`）限制在 `PROJECT_ROOT`（即 RISCV_Agent/）内。

| 工具 | 关键参数 | 说明 |
|------|---------|------|
| `run_stage` | `stage` (synth/floorplan/place/cts/route/finish) | 执行 ORFS 阶段，自动附加 `SKIP_CTS_REPAIR_TIMING=1`，1h 超时 |
| `get_metrics` | — | 读取 `results/<platform>/<nickname>/base/metadata.json`，返回 PPA 指标 |
| `read_container_file` | `path` | 读取 ORFS 容器内日志/报告 |
| `list_files_container` | `path` | 浏览 ORFS 容器内目录 |
| `read_file` | `path` | 读取宿主机文件，限制在 PROJECT_ROOT 内 |
| `write_file` | `path`, `content` | 写入宿主机文件，自动创建父目录 |

---

## 关键操作

### 启动 ORFS 容器并部署设计文件

```bash
# 1. 启动 ORFS 容器（三挂载点）
docker run -d --name orfs-agent \
  -v ./vsrc:/workspace/vsrc \
  -v ./tech:/workspace/tech \
  -v ./sky130hd:/workspace/sky130hd \
  -v ./backend:/workspace/backend \
  openroad/orfs:latest sleep infinity

# 2. 部署设计配置到容器内 ORFS designs 目录（从挂载的 /workspace/sky130hd 复制）
docker exec orfs-agent bash -c "
  mkdir -p /OpenROAD-flow-scripts/flow/designs/sky130hd/<nickname>
  cp /workspace/sky130hd/<nickname>/config.mk     /OpenROAD-flow-scripts/flow/designs/sky130hd/<nickname>/
  cp /workspace/sky130hd/<nickname>/constraint.sdc /OpenROAD-flow-scripts/flow/designs/sky130hd/<nickname>/
  cp /workspace/sky130hd/<nickname>/sram_macros.v  /OpenROAD-flow-scripts/flow/designs/sky130hd/<nickname>/
"

# 3. 解压 SRAM GDS 文件（.gds.gz → .gds）
docker exec orfs-agent bash -c \
  "for f in /workspace/tech/sram22_sky130_macros/*/*.gds.gz; do gunzip -k \"\$f\"; done"
```

### 完整流程

参考 `/flow` skill。简化为：

```
start_chipyard → generate_rtl → read_mems_conf → 更新 sram_macros.v → stop_chipyard
→ 启动 orfs-agent → 部署设计文件 → run_stage(synth) → ... → run_stage(finish)
→ get_metrics → /summary 生成报告
```

---

## RTL 来源与 SRAM 映射

`generate_rtl` 内部自动完成：

1. ChipYard `make verilog` 生成 `.fir` 和原始 `.sv`
2. **firtool 后处理**：以 `noAlwaysComb,disallowLocalVariables,disallowPackedArrays` 等 lowering options 重新编译 `.fir`，消除 Yosys 不支持的 SV 语法，split-verilog 每个模块独立输出
3. 删除验证/总线外设模块（`TLMonitor_*`、`HellaPeekingArbiter`、`TLError`、`TLAtomicAutomata`、`TLROM`、`ScratchpadSlavePort`）
4. 生成 `filelist.f` 供 `config.mk` 的 `VERILOG_FILES` 直接引用

产物输出到 `vsrc/rtl_output/chipyard.TestHarness.<Config>/verilog_synth/`。

SRAM 黑盒由 `read_mems_conf` 从 `*.mems.conf` 解析。映射示例（TinyRocketConfig）：

| 模块名 | 规格 | 映射宏 |
|--------|------|--------|
| `data_arrays_0_combMem` | 64×32, masked | `sram22_64x32m4w8` |
| `mem_combMem` | 1024×32, rw | `sram22_1024x32m8w8` |

> SRAM wrapper 需根据 `read_mems_conf` 的**实际输出**更新，不同 ChipYard 配置的黑盒名称和规格不同。

---

## Skills

| Skill | 用途 |
|-------|------|
| `/flow` | 完整前后端流程（RTL生成 → SRAM映射 → PnR → 报告），从用户 spec 中提取参数，自动完成六阶段 |
| `/summary` | 分析 ORFS 结果，生成 PPA 报告（频率/面积/拥塞/功耗/时序裕量），带五星评级 |
| `/report` | 收集 PPA 数据生成编号报告（report_N.md），交互式引导优化迭代，记录优化日志（log_N.md） |
| `/optimal` | 分 Part A（流程 Bug 修复）和 Part B（PPA 参数调优），含参数速查表 |
| `/debug` | 12 个已知问题的诊断与修复（环境配置、Yosys 错误、DRC、GDS 合并等） |

---

## config.mk 关键参数

`sky130hd/<nickname>/config.mk` 是 ORFS 设计配方，手写创建（非自动生成）：

| 参数 | 典型值 | 说明 |
|------|--------|------|
| `DESIGN_NICKNAME` | `tinyRocket` | ORFS 结果目录名 |
| `DESIGN_NAME` | `RocketTile` | 顶层模块名（必须与 RTL 一致） |
| `VERILOG_FILES` | `$(shell grep ... filelist.f)` + sram_macros.v | RTL 源文件列表 |
| `ADDITIONAL_LEFS/LIBS/GDS` | `/workspace/tech/sram22_sky130_macros/...` | SRAM 物理宏路径（容器内路径） |
| `CORE_UTILIZATION` | 45 | 核心利用率%，越大芯片越小 |
| `PLACE_DENSITY` | 0.60 | 布局密度，超 0.65 拥塞风险高 |
| `CORE_ASPECT_RATIO` | 1 | 芯片长宽比 |
| `SYNTH_HIERARCHICAL` | 1 | 分层综合，保留模块边界利于调试 |

---

## WSL2 已知问题

CTS 后 `detailed_placement` 在 WSL2 下会崩溃（illegal instruction）。`orfs-agent` MCP 的 `run_stage` 已自动附加 `SKIP_CTS_REPAIR_TIMING=1`。

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
