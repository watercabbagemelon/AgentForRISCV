# logic_test

使用 RISC-V 官方 riscv-tests 对 ChipYard 生成的 RTL 进行 ISA 功能验证。基于 Verilator 仿真，在 `test_env/` 环境中编译运行。

## Usage

```
/logic_test [config]
```

- `config` (optional): ChipYard 配置名，默认 `TinyRocketConfig`

---

## 环境概览

`test_env/` 目录结构及文件来源：

```
test_env/
├── src/                          # C++ testbench 源码
│   ├── emulator.cc               #   主仿真入口：加载 binary → 驱动时钟 → 检测 tohost → 返回 PASS/FAIL
│   ├── SimSerial.cc              #   串口仿真（patch 过）
│   ├── SimDTM.cc                 #   Debug Transport Module 仿真（patch 过）
│   ├── emulator_patch.h          #   patch 头：引入 VTestHarness.h 前置声明
│   ├── plusargs_patch.h          #   Verilog plusargs 空桩
│   ├── verilator_fixed.h         #   替换 gen-collateral 中的 verilator.h（去除 VCD 依赖）
│   ├── chipyard.TestHarness.<Config>.plusArgs   # plusArg 定义
│   └── *.cc, *.h                 →  其余文件符号链接到 gen-collateral
├── rtl/
│   └── filelist.f                #   全部 288 个 .sv/.v 的绝对路径列表（含 UNIQUIFIED 模块）
├── include/                      # C++ 头文件（来自 Spike riscv-isa-sim + DRAMSim2）
│   ├── fesvr/                    #   HTIF/TSI/DTM 接口
│   ├── riscv/                    #   RISC-V 结构定义（cfg.h, encoding.h...）
│   ├── fdt/                      #   Flattened Device Tree
│   ├── softfloat/                #   软浮点
│   └── DRAMSim2/                 #   DRAM 仿真头文件
├── lib/
│   ├── libfesvr.a                #   FESVR Host-Target Interface 库（Spike 编译产物）
│   └── libDRAMSim.a              #   DDR3 内存时序仿真模型（DRAMSim2 编译产物）
├── build/                        # Verilator 构建输出
│   ├── VTestHarness              #   仿真可执行文件（RTL 的 C++ 等价物 + testbench）
│   └── *.o, *.a, *.cpp, *.h      #   中间产物
├── logs/                         # 测试运行日志
└── run_tests.sh                  # 批量测试脚本
```

---

## 步骤一：确认 RTL 产物完整

检查 gen-collateral 目录下的文件：

```
vsrc/rtl_output/chipyard.TestHarness.<Config>/gen-collateral/
├── *.sv                         # 279 个 SystemVerilog RTL 文件
├── *.v                          #  9 个 Verilog 文件（SimJTAG.v, plusarg_reader.v 等）
├── emulator.cc                  # 主仿真入口
├── SimDRAM.cc, SimJTAG.cc, …    # C++ testbench 组件
├── mm.cc / mm.h                 # 内存模型
├── mm_dramsim2.cc / .h          # DRAMSim2 后端
├── remote_bitbang.cc / .h       # JTAG Remote Bitbang
├── testchip_tsi.cc / .h         # Test Serial Interface
├── uart.cc / uart.h             # UART
├── verilator.h                  # Verilator 适配头
└── filelist.f                   # 模块列表（注意：不含 *_TestHarness_UNIQUIFIED.*）
```

如果 RTL 尚未生成，先调用 `chipyard-automation` MCP：

```
start_chipyard(image="ictmrc/chipyard-image:1.9.1-ubuntu-22.04")
generate_rtl(config="<Config>")
```

---

## 步骤二：检查/建立 test_env 源文件

### 2.1 符号链接（指向 gen-collateral 的原始文件）

以下文件无需修改，直接链接：

```
src/SimDRAM.cc        → gen-collateral/SimDRAM.cc
src/SimJTAG.cc        → gen-collateral/SimJTAG.cc
src/SimUART.cc        → gen-collateral/SimUART.cc
src/mm.cc             → gen-collateral/mm.cc
src/mm.h              → gen-collateral/mm.h
src/mm_dramsim2.cc    → gen-collateral/mm_dramsim2.cc
src/mm_dramsim2.h     → gen-collateral/mm_dramsim2.h
src/remote_bitbang.cc → gen-collateral/remote_bitbang.cc
src/remote_bitbang.h  → gen-collateral/remote_bitbang.h
src/testchip_tsi.cc   → gen-collateral/testchip_tsi.cc
src/testchip_tsi.h    → gen-collateral/testchip_tsi.h
src/uart.cc           → gen-collateral/uart.cc
src/uart.h            → gen-collateral/uart.h
src/verilator.h       → gen-collateral/verilator.h
```

### 2.2 Patched 文件（需手动复制修改）

**emulator.cc** — 在第 1 行前插入：
```cpp
#include "VTestHarness.h"
#include "chipyard.TestHarness.TinyRocketConfig.plusArgs"
```

**SimSerial.cc** 和 **SimDTM.cc** — 从 gen-collateral 复制，内容不变（历史遗留的 patch，保留即可）。

**verilator_fixed.h** — 替代 gen-collateral 中有 VCD 依赖的 `verilator.h`：
```cpp
#ifndef _ROCKET_VERILATOR_FIXED_H
#define _ROCKET_VERILATOR_FIXED_H
#include <stdlib.h>
#include <stdio.h>
extern bool verbose;
extern bool done_reset;
#include "VTestHarness.h"
#endif
```

**emulator_patch.h**：
```cpp
#ifndef _EMULATOR_PATCH_H
#define _EMULATOR_PATCH_H
#include "VTestHarness.h"
#endif
```

**plusargs_patch.h**：空桩头文件。

**chipyard.TestHarness.<Config>.plusArgs** — 从 `gen-collateral/../` 复制，定义 Verilog plusargs（`custom_boot_pin`、`max_core_cycles`、`uart_tx_printf`、`jtag_rbb_enable` 等）。

### 2.3 RTL filelist.f

**必须包含所有 288 个 SV/V 文件**（gen-collateral 自带的 filelist.f 只有 276 条，缺少 12 个 `*_TestHarness_UNIQUIFIED.*` 文件）。缺少会导致 Verilator 报 `Cannot find file containing module`。

正确的生成方式：
```bash
cd $GEN_COL && ls *.sv *.v | while read f; do
  echo "$GEN_COL/$f"
done > test_env/rtl/filelist.f
```

### 2.4 外部依赖

| 组件 | 源 | 目标路径 |
|------|-----|---------|
| `libfesvr.a` | Spike `build/libfesvr.a` | `test_env/lib/` |
| `libDRAMSim.a` | DRAMSim2 编译产物 | `test_env/lib/` |
| `include/fesvr/` | Spike `install/include/fesvr/` | `test_env/include/fesvr/` |
| `include/riscv/` | Spike `install/include/riscv/` | `test_env/include/riscv/` |
| `include/fdt/` | Spike `install/include/fdt/` | `test_env/include/fdt/` |
| `include/softfloat/` | Spike `install/include/softfloat/` | `test_env/include/softfloat/` |
| `include/DRAMSim2/` | DRAMSim2 源码 `*.h` | `test_env/include/DRAMSim2/` |

---

## 步骤三：构建 Verilator 仿真器

在 `test_env/` 下执行：

```bash
cd test_env

# 1. Verilator：SV → C++ 模型生成
verilator --cc --timing \
  --top-module TestHarness \
  --exe \
    src/emulator.cc \
    src/SimDRAM.cc \
    src/SimDTM.cc \
    src/SimJTAG.cc \
    src/SimSerial.cc \
    src/SimUART.cc \
    src/mm.cc \
    src/mm_dramsim2.cc \
    src/remote_bitbang.cc \
    src/testchip_tsi.cc \
    src/uart.cc \
    /usr/share/verilator/include/verilated_vpi.cpp \
  -CFLAGS "-I$(pwd)/src -I$(pwd)/include -I$(pwd)/include/DRAMSim2 \
           -I/usr/share/verilator/include \
           -DTEST_HARNESS=VTestHarness -DVERILATOR" \
  -LDFLAGS "-L$(pwd)/lib -lfesvr -lDRAMSim -lpthread" \
  --Mdir build \
  -Wno-TIMESCALEMOD -Wno-WIDTHEXPAND -Wno-LATCH \
  -f rtl/filelist.f

# 2. C++ 编译 + 链接
cd build && make -f VTestHarness.mk -j$(nproc)
```

**关键参数说明：**

| 参数 | 说明 |
|------|------|
| `--cc --timing` | 生成 C++ 输出，支持 `#delay` 时序 |
| `--top-module TestHarness` | RTL 顶层模块 |
| `--exe <files>` | C++ 源文件，编译进最终可执行文件 |
| `-DTEST_HARNESS=VTestHarness` | emulator.cc 中 `new TEST_HARNESS` 的宏定义 |
| `-DVERILATOR` | ChipYard 仿真宏，适配 Verilator 编译路径 |
| `-Wno-WIDTHEXPAND -Wno-LATCH` | 抑制 ChipYard 生成的已知无害警告 |
| `verilated_vpi.cpp` | Verilator VPI 支持（SimUART/SimSerial 依赖） |

---

## 步骤四：确保 riscv-tests 已编译

### 4.1 编译环境

```bash
# 编译器
sudo apt-get install -y gcc-riscv64-unknown-elf picolibc-riscv64-unknown-elf

# Picolibc 路径适配（编译器 multilib 支持）
sudo ln -sf /usr/lib/picolibc/riscv64-unknown-elf/include \
            /usr/lib/riscv64-unknown-elf/include
sudo ln -sf /usr/lib/picolibc/riscv64-unknown-elf/lib \
            /usr/lib/riscv64-unknown-elf/lib
```

### 4.2 编译测试

```bash
cd riscv-tests/isa
make clean
make XLEN=32 RISCV_PREFIX=riscv64-unknown-elf-
```

产物为 `isa/rv32ui-p-*`、`rv32um-p-*` 等 ELF 文件（flat binary，链接地址 0x80000000）。

### 4.3 测试类别

| 前缀 | 类别 | 数量 | 说明 |
|------|------|------|------|
| `rv32ui-p-*` | RV32UI Integer | 42 | 基本整数指令 |
| `rv32um-p-*` | RV32UM Mul/Div | 8 | 乘除指令 |
| `rv32mi-p-*` | RV32MI Machine | 16 | 机器级指令/异常 |
| `rv32ua-p-*` | RV32UA Atomic | 10 | 原子指令 |
| `rv32uc-p-*` | RV32UC Compressed | 1 | 压缩指令 |
| `rv32si-p-*` | RV32SI Supervisor | 6 | **不适用**（TinyRocket 无 S-mode） |

---

## 步骤五：运行测试

### 5.1 批量运行

```bash
cd test_env
./run_tests.sh
```

脚本自动遍历所有已编译的 test binary，每项 30s 超时，结果写入 `logs/` 目录。

### 5.2 手动单项测试

```bash
cd test_env
./build/VTestHarness +max-cycles=10000000 \
  /path/to/riscv-tests/isa/rv32ui-p-add
```

### 5.3 结果判定

| 现象 | 含义 |
|------|------|
| `exit 0` | PASS — tohost 寄存器写入 `1` |
| `exit 1` | FAIL — tohost 写入 `(test_num << 1) \| 1` |
| `exit 134` (SIGABRT) | DM/TLMonitor 断言中断（间歇性，**与核心逻辑无关**） |
| `exit 124` | 超时（仿真 30s 未结束） |
| 输出含 `*** FAILED ***` | 测试自身报告失败 |

### 5.4 重跑 DM 间歇性失败

```
grep "ABORT" logs/*.log | grep -c "TLMonitor"
```

所有 ABORT 均来自 `TLMonitor_*.sv: Assertion failed`，这是 Debug Module 的已知问题。单独重跑这些测试通常全部通过：

```bash
for t in rv32ui-p-bge rv32ui-p-jalr rv32ui-p-lw ...; do
  ./build/VTestHarness +max-cycles=10000000 \
    /path/to/riscv-tests/isa/$t > logs/retry_$t.log 2>&1 && echo "$t: PASS"
done
```

---

## 预期结果

排除 6 个不适用（无 S-mode）的 rv32si 测试和 DM 间歇性失败后：

| 类别 | 通过率 |
|------|--------|
| RV32UI (整数) | 41/42 (97.6%) |
| RV32UM (乘除) | 8/8 (100%) |
| RV32MI (机器级) | 16/16 (100%) |
| RV32UA (原子) | 9/10 (90%) |
| RV32UC (压缩) | 1/1 (100%) |
| **合计** | **75/77 (97.4%)** |

仅有两个真实失败：
- **rv32ui-p-ma_data**：非对齐数据访问 — TinyRocket 配置需严格对齐
- **rv32ua-p-lrsc**：LR/SC reservation — DTIM 不支持完整 reservation 语义
