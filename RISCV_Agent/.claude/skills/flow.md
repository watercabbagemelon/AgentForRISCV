# flow

完整执行 RISC-V 芯片前后端实现流程，从用户需求分析到最终 PPA 报告。
前端通过 `chipyard-automation` MCP 操作，后端通过 `orfs-agent` MCP 操作。

## Usage

```
/flow [spec描述]
```

- `spec描述` (optional): 用户对设计的需求描述，如目标频率、工艺、ChipYard 配置名等

---

## 步骤一：分析用户指令，确定 Spec 指标

从用户指令中提取以下关键参数，未指定时使用默认值：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| ChipYard 配置名 | `TinyRocketConfig` | 传给 `generate_rtl` 的 `config` 参数 |
| ORFS 设计昵称 | `tinyRocket` | `config.mk` 中的 `DESIGN_NICKNAME` |
| 顶层模块 | `RocketTile` | `config.mk` 中的 `DESIGN_NAME` |
| 目标频率 | 50 MHz（周期 20 ns） | `constraint.sdc` 时序约束基准 |
| 工艺节点 | `sky130hd`（SkyWater 130nm） | ORFS 平台名 |
| 核心利用率 | 45% | `CORE_UTILIZATION` |
| 布局密度 | 0.60 | `PLACE_DENSITY` |
| 长宽比 | 1（正方形） | `CORE_ASPECT_RATIO` |

将确认后的参数记录，后续所有步骤中的 `<config>` 均替换为实际配置名（如 `TinyRocketConfig`）。

---

## 步骤二：启动 ChipYard 容器，生成 RTL

### 2.1 启动容器

调用 `chipyard-automation` MCP：

```
start_chipyard(image="ictmrc/chipyard-image:1.9.1-ubuntu-22.04")
```

容器名固定为 `chipyard-agent`，自动挂载宿主机 `vsrc/` 到容器内 `/workspace/vsrc`。

### 2.2 生成 RTL 并后处理为可综合 Verilog

```
generate_rtl(config="<config>")
```

工具内部自动完成两步：
1. 容器内激活 conda，运行 `make verilog CONFIG=<config>`，结果复制到 `vsrc/rtl_output/chipyard.TestHarness.<config>/`
2. **firtool 后处理**：以 `noAlwaysComb,disallowLocalVariables` 等 lowering options 重新编译 `.fir`，消除 `always_ff`/`always_comb` 等 Yosys 不支持的 SV 语法，删除验证/外设模块，生成 `verilog_synth/filelist.f`

超时上限：30 分钟（make）+ 5 分钟（firtool 后处理）

**产物：**
- 原始 SV：`vsrc/rtl_output/chipyard.TestHarness.<config>/gen-collateral/`
- **可综合 Verilog（ORFS 使用此目录）**：`vsrc/rtl_output/chipyard.TestHarness.<config>/verilog_synth/`
- 文件列表：`vsrc/rtl_output/chipyard.TestHarness.<config>/verilog_synth/filelist.f`

### 2.2.1 firtool SV→V 转换原理

ChipYard 默认输出 SystemVerilog（`.sv`），包含 Yosys 不支持的语法。`generate_rtl` 内部通过 firtool 重新编译 `.fir` 源文件，强制输出纯 Verilog：

**关键 firtool 参数：**

```bash
firtool <design>.fir \
  --format=fir \
  --lowering-options=noAlwaysComb,disallowLocalVariables,disallowPackedArrays,locationInfoStyle=none \
  --repl-seq-mem --repl-seq-mem-file=<design>.mems.conf \
  --split-verilog \
  -o verilog_synth/
```

| 参数 | 作用 |
|------|------|
| `noAlwaysComb` | 将 `always_comb` 改写为 `always @(*)` |
| `disallowLocalVariables` | 消除块内局部变量声明（Yosys 不支持） |
| `disallowPackedArrays` | 展开 packed struct/array（Yosys 不支持） |
| `locationInfoStyle=none` | 去除行号注释，减小文件体积 |
| `--repl-seq-mem` | 将 FIRRTL SRAM 提取为黑盒，生成 `.mems.conf` |
| `--split-verilog` | 每个模块输出独立 `.sv` 文件 |

**输出文件扩展名说明：**

firtool 输出文件扩展名仍为 `.sv`，但内容已是纯 Verilog 语法（无 SV 特有结构）。Yosys 可直接读取，无需重命名为 `.v`。

**手动执行（如需在容器内重跑后处理）：**

```bash
docker exec chipyard-agent bash -c "
  source /workspace/chipyard/.conda-env/etc/profile.d/conda.sh
  conda activate /workspace/chipyard/.conda-env
  cd /workspace/chipyard

  FIRFILE=\$(find /workspace/vsrc/rtl_output/chipyard.TestHarness.<config>/ -name '*.fir' | head -1)
  OUTDIR=/workspace/vsrc/rtl_output/chipyard.TestHarness.<config>/verilog_synth

  mkdir -p \$OUTDIR
  firtool \$FIRFILE \
    --format=fir \
    --lowering-options=noAlwaysComb,disallowLocalVariables,disallowPackedArrays,locationInfoStyle=none \
    --repl-seq-mem --repl-seq-mem-file=\$OUTDIR/<config>.mems.conf \
    --split-verilog -o \$OUTDIR/

  # 生成 filelist.f（排除 SRAM 黑盒行为模型）
  find \$OUTDIR -name '*.sv' \
    | grep -vE '(data_arrays_0_combMem|data_arrays_0_0_combMem|mem_combMem|tag_array_0_combMem)\.sv' \
    > \$OUTDIR/filelist.f
"
```

**需要从 filelist.f 排除的 SRAM 行为模型：**

firtool 会为每个 `--repl-seq-mem` 提取的黑盒生成同名 `.sv` 行为模型（用于仿真），这些文件不能进入综合，否则与 `sram_macros.v` 中的 wrapper 产生模块重定义冲突。在 `config.mk` 中用 `grep -vE` 过滤：

```makefile
export VERILOG_FILES = \
  $(shell grep -vE '(data_arrays_0_combMem|data_arrays_0_0_combMem|mem_combMem|tag_array_0_combMem)\.sv' \
    /workspace/vsrc/rtl_output/chipyard.TestHarness.<config>/verilog_synth/filelist.f) \
  $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram_macros.v
```

> 过滤模式需与 `read_mems_conf` 返回的实际黑盒名称保持一致，不同 ChipYard 配置的黑盒名称不同。

### 2.3 确认生成产物

```
list_rtl_files(config="<config>")
list_rtl_files(config="<config>", subdir="verilog_synth")
```

关注：`verilog_synth/` 下是否有 `.sv` 文件和 `filelist.f`。

### 2.4 解析 SRAM 需求

```
read_mems_conf(config="<config>")
```

返回结构化 SRAM 黑盒列表（名称/深度/宽度/类型），据此确定步骤三的映射方案。

SRAM 黑盒由 firtool 的 `--repl-seq-mem` 选项从 ChipYard RTL 中提取，模块名为 `*_combMem` 格式。
TinyRocketConfig 对应的黑盒（供参考，以 `read_mems_conf` 实际输出为准）：

| 模块名 | 深度×宽度 | 类型 |
|--------|-----------|------|
| `data_arrays_0_combMem` | 64×32 | mrw, mask_gran=8 |
| `mem_combMem` | 1024×32 | rw |

### 2.5 停止容器（可选）

RTL 生成完成后可释放资源：

```
stop_chipyard()
```

---

## 步骤三：SRAM 工艺映射

### 3.1 映射策略（以 TinyRocketConfig 为例）

| FIRRTL 模块 | 映射方案 | 说明 |
|-------------|---------|------|
| `data_arrays_0_ext` (64×32, masked) | `sram22_64x32m4w8` | wmask[3:0] 对应 4 字节 |
| `tag_array_ext` (4×25, rw) | 寄存器堆（flop） | 太小，无合适宏 |
| `data_arrays_0_0_ext` (64×32, rw) | `sram22_64x32m4w8` | wmask 固定 4'hF |
| `mem_ext` (1024×32, 1R+1W) | `sram22_1024x32m8w8` | 写优先仲裁伪双端口 |

可用宏位于 `tech/sram22_sky130_macros/`，规格从 64×8 到 2048×64 均有覆盖。

### 3.2 检查/更新 SRAM wrapper

使用 `orfs-agent` MCP 读取当前 wrapper：

```
read_file("sky130hd/<design_nickname>/sram_macros.v")
```

如需修改，使用 `write_file` 更新：

```
write_file("sky130hd/<design_nickname>/sram_macros.v", "<新内容>")
```

### 3.3 sram22 宏接口（以 64×32 为例）

```verilog
module sram22_64x32m4w8(
  input        clk,    // 上升沿触发
  input        rstb,   // 复位低有效，通常接 1'b1
  input        ce,     // 片选
  input        we,     // 写使能
  input  [3:0] wmask,  // 写掩码（每位对应 8 bits）
  input  [5:0] addr,
  input  [31:0] din,
  output [31:0] dout   // 1 cycle 延迟
);
```

---

## 步骤四：配置并部署到 ORFS 容器

### 4.1 检查/更新 config.mk

```
read_file("sky130hd/<design_nickname>/config.mk")
```

如需根据 spec 调整参数（频率、利用率等），使用 `write_file` 更新后重新部署。

关键参数：

```makefile
export DESIGN_NICKNAME = <design_nickname>
export DESIGN_NAME     = <top_module>        # ChipYard 生成的顶层模块名（如 RocketTile）
export PLATFORM        = sky130hd
export CORE_UTILIZATION  = 45
export CORE_ASPECT_RATIO = 1
export PLACE_DENSITY     = 0.60

# 使用 ChipYard 生成的可综合 Verilog（firtool 后处理产物）
export VERILOG_FILES = $(shell cat /workspace/vsrc/rtl_output/chipyard.TestHarness.<config>/verilog_synth/filelist.f)
```

### 4.2 检查/更新 constraint.sdc

```
read_file("sky130hd/<design_nickname>/constraint.sdc")
```

目标频率变化时修改时钟周期：

```tcl
create_clock [get_ports clk] -name core_clk -period <period_ns>
```

### 4.3 部署设计文件到 ORFS 容器

使用 `orfs-agent` MCP 的 `run_stage` 前，需先将配置文件部署到容器内。
通过 `read_container_file` 确认容器已启动，然后执行部署：

```
run_stage(stage="synth")
```

> 若容器未启动，先手动运行：
> ```bash
> docker run -d --name orfs-agent \
>   -v ./vsrc:/workspace/vsrc \
>   -v ./tech:/workspace/tech \
>   -v ./sky130hd:/workspace/sky130hd \
>   -v ./backend:/workspace/backend \
>   openroad/orfs:latest sleep infinity
> ```
> 再通过 `write_file` + 部署脚本将设计文件复制到容器内 `designs/sky130hd/<nickname>/` 目录。

---

## 步骤五：利用 orfs-agent MCP 完成后端流程

依次调用 `run_stage`，每阶段完成后用 `read_container_file` 检查日志再继续。

所有日志路径格式：
```
/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/<step>.log
```

### 5.1 逻辑综合

```
run_stage(stage="synth")
```

检查日志：
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/1_1_yosys.log")
```
关注：`Chip area`、`Number of cells`、是否有 `ERROR`。

### 5.2 布图规划

```
run_stage(stage="floorplan")
```

检查日志：
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/2_1_floorplan.log")
```
关注：宏摆放位置、core area 是否合理。

### 5.3 布局

```
run_stage(stage="place")
```

检查日志：
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/3_1_place.log")
```
关注：`HPWL`、`overflow`（应 < 0.1）。

### 5.4 时钟树综合

```
run_stage(stage="cts")
```

> WSL2 下 `orfs-agent` MCP 已自动附加 `SKIP_CTS_REPAIR_TIMING=1`，无需手动处理。

检查日志：
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/4_1_cts.log")
```
关注：时钟树深度、skew。

### 5.5 布线

```
run_stage(stage="route")
```

> 耗时最长（30~60 分钟），MCP 已设置 1 小时超时。

检查日志：
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/5_1_fastroute.log")
```
关注：DRC violations（应为 0）。

### 5.6 收尾

```
run_stage(stage="finish")
```

---

## 步骤六：读取报告，给出结果

### 6.1 读取 PPA 指标

```
get_metrics()
```

关键字段：

| 字段 | 含义 |
|------|------|
| `finish__timing__setup__ws` | WNS（≥ 0 表示无违例） |
| `finish__design__instance__area__stdcell` | 标准单元面积 (µm²) |
| `finish__power__total` | 总功耗 (W) |
| `finish__design__instance__count__stdcell` | 标准单元数量 |

### 6.2 读取时序报告

```
read_container_file("/OpenROAD-flow-scripts/flow/reports/sky130hd/<design_nickname>/base/6_finish.rpt")
```

### 6.3 读取面积/功耗摘要

```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/6_report.log")
```

### 6.4 计算 Fmax

```
Fmax = 1 / (T_clk - WNS)
```

例：T_clk = 20 ns，WNS = +9.40 ns → Fmax = 1 / (20 - 9.40) ns = **94.31 MHz**

### 6.5 结果汇总模板

| 指标 | 数值 |
|------|------|
| 工艺节点 | SkyWater 130nm (sky130hd) |
| ChipYard 配置 | `<config>` |
| 目标时钟周期 | ___ ns (___ MHz) |
| WNS | ___ ns |
| Fmax | ___ MHz |
| 设计面积 | ___ µm² |
| 核心利用率 | ___% |
| 总功耗 | ___ mW |
| SRAM 宏数量 | ___ |
| 触发器数量 | ___ |

---

## MCP 工具速查

| MCP | 工具 | 用途 |
|-----|------|------|
| `chipyard-automation` | `start_chipyard` | 启动 ChipYard 容器 |
| `chipyard-automation` | `generate_rtl` | 生成 RTL |
| `chipyard-automation` | `read_mems_conf` | 解析 SRAM 黑盒列表 |
| `chipyard-automation` | `list_rtl_files` | 列出 RTL 输出文件 |
| `chipyard-automation` | `read_rtl_file` | 读取 RTL 文件内容 |
| `chipyard-automation` | `stop_chipyard` | 停止容器 |
| `orfs-agent` | `run_stage` | 执行后端流程阶段 |
| `orfs-agent` | `get_metrics` | 读取 PPA 指标 |
| `orfs-agent` | `read_container_file` | 读取容器内日志/报告 |
| `orfs-agent` | `list_files_container` | 浏览容器内目录 |
| `orfs-agent` | `read_file` | 读取宿主机设计文件 |
| `orfs-agent` | `write_file` | 更新宿主机设计文件 |

---

## 参考

- 调试问题 → `/debug`
- ChipYard MCP 源码 → `mcp_server/src/chipyard.js`
- ORFS MCP 源码 → `mcp_server/src/index.js`
- 设计配置 → `sky130hd/<design_nickname>/config.mk`
- 时序约束 → `sky130hd/<design_nickname>/constraint.sdc`
- SRAM wrapper → `sky130hd/<design_nickname>/sram_macros.v`
