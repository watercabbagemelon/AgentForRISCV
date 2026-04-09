# ALU 验证报告

**日期**: 2026-03-27
**模块**: ALU (RV32I)
**操作**: ADD / SUB / AND / OR / XOR / SLT
**zero 标志位**: 支持

---

## 仿真结果摘要

| 项目 | 数量 |
|------|------|
| 总测试数 | 15 |
| 通过 | 15 |
| 失败 | 0 |

---

## 详细测试结果

| 测试名 | a | b | op | 期望结果 | 实际结果 | 期望zero | 实际zero | 状态 |
|--------|---|---|----|----------|----------|----------|----------|------|
| ADD | 0x00000005 | 0x00000003 | 0 | 0x00000008 | 0x00000008 | 0 | 0 | PASS |
| ADD_ZERO | 0x00000000 | 0x00000000 | 0 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| ADD_OVERFLOW | 0xFFFFFFFF | 0x00000001 | 0 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| SUB | 0x0000000A | 0x00000003 | 1 | 0x00000007 | 0x00000007 | 0 | 0 | PASS |
| SUB_ZERO | 0x00000005 | 0x00000005 | 1 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| SUB_NEG | 0x00000003 | 0x0000000A | 1 | 0xFFFFFFF9 | 0xFFFFFFF9 | 0 | 0 | PASS |
| AND | 0xFF00FF00 | 0x0F0F0F0F | 2 | 0x0F000F00 | 0x0F000F00 | 0 | 0 | PASS |
| AND_ZERO | 0xAAAAAAAA | 0x55555555 | 2 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| OR | 0xFF000000 | 0x00FF0000 | 3 | 0xFFFF0000 | 0xFFFF0000 | 0 | 0 | PASS |
| OR_ZERO | 0x00000000 | 0x00000000 | 3 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| XOR | 0xFFFFFFFF | 0xFFFFFFFF | 4 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| XOR_BASIC | 0xA5A5A5A5 | 0x5A5A5A5A | 4 | 0xFFFFFFFF | 0xFFFFFFFF | 0 | 0 | PASS |
| SLT_TRUE | 0xFFFFFFFF | 0x00000000 | 5 | 0x00000001 | 0x00000001 | 0 | 0 | PASS |
| SLT_FALSE | 0x00000005 | 0x00000003 | 5 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| SLT_EQUAL | 0x00000007 | 0x00000007 | 5 | 0x00000000 | 0x00000000 | 1 | 1 | PASS |

---

## Verilator WARNING 说明

**WARNING**: Verilator 调用时出现 `Can't locate Pod/Usage.pm` 错误，原因是系统 PATH 中 msys perl 缺少 `Pod::Usage` 模块，与 ucrt64 perl 路径不一致。
**解决方式**: 通过显式设置 `PERL5LIB=/d/msys/ucrt64/lib/perl5/core_perl` 绕过，Verilator 本身功能正常，lint 和编译均无 ERROR。

---

## 生成文件

| 文件 | 说明 |
|------|------|
| `src/ALU.scala` | Chisel 源码 |
| `generated/top.sv` | 生成的 SystemVerilog |
| `testbench/alu_tb.cpp` | C++ Testbench |
| `sim/logs/sim_result.log` | 仿真原始日志 |
| `sim/logs/validation_report.md` | 本报告 |
