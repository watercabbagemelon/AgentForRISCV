# TinyRocket Verilator 仿真测试环境

## 目录结构

```
test_env/
├── src/                          # C++ testbench 源码
│   ├── emulator.cc               #   主仿真入口（patched）
│   ├── SimSerial.cc              #   串口仿真（patched）
│   ├── SimDTM.cc                 #   Debug Transport Module 仿真（patched）
│   ├── SimDRAM.cc                →   符号链接到 gen-collateral
│   ├── SimJTAG.cc                →   符号链接
│   ├── SimUART.cc                →   符号链接
│   ├── mm.cc / mm.h              →   内存模型基类
│   ├── mm_dramsim2.cc/.h         →   DRAMSim2 内存后端
│   ├── remote_bitbang.cc/.h      →   JTAG Remote Bitbang
│   ├── testchip_tsi.cc/.h        →   Test Serial Interface (HTIF)
│   ├── uart.cc / uart.h          →   UART 实现
│   ├── verilator.h               →   符号链接
│   ├── verilator_fixed.h         #   替换头（VTestHarness 引用）
│   ├── emulator_patch.h          #   patch 头
│   ├── plusargs_patch.h          #   Verilog plusargs 桩
│   └── chipyard.TestHarness.TinyRocketConfig.plusArgs
├── rtl/
│   └── filelist.f                # RTL 文件列表（288 个 .sv/.v 绝对路径）
├── include/                      # 外部 C++ 头文件
│   ├── fesvr/                    #   来自 Spike/riscv-isa-sim
│   ├── riscv/                    #   来自 Spike
│   ├── fdt/                      #   来自 Spike
│   ├── softfloat/                #   来自 Spike
│   └── DRAMSim2/                 #   来自 DRAMSim2
├── lib/                          # 外部静态库
│   ├── libfesvr.a                #   FESVR Host-Target Interface
│   └── libDRAMSim.a              #   DRAM 仿真模型
├── build/                        # Verilator 构建输出
│   ├── VTestHarness              #   仿真可执行文件
│   ├── VTestHarness.mk           #   Makefile
│   ├── VTestHarness.cpp/.h       #   Verilator 生成的 C++ 模型
│   └── *.o / *.a                 #   中间编译产物
├── logs/                         # 测试日志
├── run_tests.sh                  # 测试运行脚本
└── README.md                     # 本文件
```

## 文件来源

| 文件 | 来源 | 说明 |
|---|---|---|
| gen-collateral (SV/C++) | ChipYard Docker `make verilog` 生成 | 279 个 SV + 11 个 C++ 文件 |
| libfesvr.a + include/ | [Spike](https://github.com/riscv-software-src/riscv-isa-sim) 编译 | Host-Target Interface 库 |
| libDRAMSim.a | [DRAMSim2](https://github.com/umd-memsys/DRAMSim2) 编译 | DDR3 内存时序模型 |
| emulator.cc (patched) | gen-collateral + 手动 patch | 添加 `VTestHarness.h` + plusArgs 引用 |
| verilator_fixed.h | 手动创建 | 替换有问题的 verilator.h |

## 构建

```bash
cd test_env

# Verilator: SV → C++ 模型生成
verilator --cc --timing \
  --top-module TestHarness \
  --exe src/emulator.cc src/SimDRAM.cc ... \
  -CFLAGS "-I$(pwd)/src -I$(pwd)/include -I$(pwd)/include/DRAMSim2 \
           -DTEST_HARNESS=VTestHarness -DVERILATOR" \
  -LDFLAGS "-L$(pwd)/lib -lfesvr -lDRAMSim -lpthread" \
  --Mdir build \
  -Wno-TIMESCALEMOD -Wno-WIDTHEXPAND -Wno-LATCH \
  -f rtl/filelist.f

# C++ 编译 + 链接
cd build && make -f VTestHarness.mk -j$(nproc)
```

## 运行测试

```bash
cd test_env

# 运行完整测试套件（RV32UI/UM/MI/UA/UC）
./run_tests.sh

# 运行特定类别
./run_tests.sh "rv32ui:Integer rv32um:MulDiv"

# 手动运行单个测试
./build/VTestHarness +max-cycles=10000000 \
  /path/to/riscv-tests/isa/rv32ui-p-add
```

## 测试原理

VTestHarness 是一个 Verilator 编译的 RTL 仿真器：
1. 加载 RISC-V 二进制到仿真内存 (0x80000000)
2. 启动 TinyRocket 核心执行
3. FESVR 监控 `tohost` 寄存器
4. tohost = 1 → PASS (exit 0), tohost > 1 → FAIL (exit 非 0)
