# ALU 验证报告

**生成时间**: 2026-04-12  
**模块**: ALU (RV32I 对齐)  
**工具链**: Chisel 6.2.0 → firtool-1.62.0 → Verilator 5.020

---

## 模块接口

| 端口 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `clock` | Input | 1 | 时钟（组合逻辑未使用） |
| `reset` | Input | 1 | 复位（组合逻辑未使用） |
| `io_a` | Input | 32 | 操作数 A |
| `io_b` | Input | 32 | 操作数 B |
| `io_op` | Input | 3 | 操作码（0=ADD,1=SUB,2=AND,3=OR,4=XOR,5=SLT） |
| `io_result` | Output | 32 | 运算结果 |
| `io_zero` | Output | 1 | 结果为零标志 |

---

## Verilator Lint 检查

状态: **PASSED** (无 ERROR，无 WARNING)

---

## 仿真测试结果

| 测试用例 | a | b | op | 期望结果 | 实际结果 | 期望zero | 实际zero | 状态 |
|----------|---|---|----|----------|----------|----------|----------|------|
| ADD | 0x00000005 | 0x00000003 | ADD | 0x00000008 | 0x00000008 | 0 | 0 | PASS |
| ADD_ZERO | 0x00000000 | 0x00000000 | ADD | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| ADD_OVERFLOW | 0xFFFFFFFF | 0x00000001 | ADD | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| SUB | 0x0000000A | 0x00000003 | SUB | 0x00000007 | 0x00000007 | 0 | 0 | PASS |
| SUB_ZERO | 0x00000005 | 0x00000005 | SUB | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| SUB_NEG | 0x00000003 | 0x0000000A | SUB | 0xFFFFFFF9 | 0xFFFFFFF9 | 0 | 0 | PASS |
| AND | 0xFF00FF00 | 0x0F0F0F0F | AND | 0x0F000F00 | 0x0F000F00 | 0 | 0 | PASS |
| AND_ZERO | 0xAAAAAAAA | 0x55555555 | AND | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| OR | 0xFF000000 | 0x00FF0000 | OR | 0xFFFF0000 | 0xFFFF0000 | 0 | 0 | PASS |
| OR_ZERO | 0x00000000 | 0x00000000 | OR | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| XOR | 0xFFFFFFFF | 0xFFFFFFFF | XOR | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| XOR_BASIC | 0xA5A5A5A5 | 0x5A5A5A5A | XOR | 0xFFFFFFFF | 0xFFFFFFFF | 0 | 0 | PASS |
| SLT_TRUE | 0xFFFFFFFF(-1) | 0x00000000 | SLT | 0x00000001 | 0x00000001 | 0 | 0 | PASS |
| SLT_FALSE | 0x00000005 | 0x00000003 | SLT | 0x00000000 | 0x00000000 | 1 | 1 | PASS |
| SLT_EQUAL | 0x00000007 | 0x00000007 | SLT | 0x00000000 | 0x00000000 | 1 | 1 | PASS |

---

## 汇总

| 项目 | 数量 |
|------|------|
| 总测试数 | 15 |
| 通过 | **15** |
| 失败 | 0 |

**结论**: 所有测试用例通过，ALU 功能验证完成。
