# ALU 后端流程汇总报告

**设计名称**: ALU  
**工艺平台**: sky130hd  
**时钟约束**: 10.0 ns (100 MHz)  
**流程工具**: OpenROAD Flow Scripts (ORFS) + Yosys + KLayout  
**生成日期**: 2026-04-13  

---

## 1. 综合（Synthesis）

**工具**: Yosys 0.63+post  
**输入**: `/workspace/design/rtl/alu.sv`  

| 指标 | 数值 |
|------|------|
| 综合后标准单元数 | 857 |
| 综合面积 | 5589.1 um² |
| 运行时间 | 5.11 s |
| 峰值内存 | 58.9 MB |

**说明**: ALU 为纯组合逻辑，无寄存器/触发器。使用 ABC speed script 进行技术映射，目标库 sky130_fd_sc_hd__tt_025C_1v80。

---

## 2. 布图规划（Floorplan）

**工具**: OpenROAD  

| 指标 | 数值 |
|------|------|
| Die 面积 | 300 × 300 um = 90000 um² |
| Core 面积 | 77594.4 um² |
| 标准单元面积 | 5589.1 um² |
| 利用率 | 7.2% |
| 行数 | 102 rows |
| Tap cell 数 | 1040 |

**子步骤**:
- 2_1 Floorplan: Die/Core 定义，IO 放置
- 2_2 Macro Place: 无宏单元，跳过
- 2_3 Tapcell: 插入 1040 个 tap cell
- 2_4 PDN: 电源网络生成（VDD/VSS）

---

## 3. 布局（Placement）

**工具**: OpenROAD (RePlAce + OpenDP)  

| 指标 | 数值 |
|------|------|
| 布局后面积 | 7774 um² |
| 利用率 | 10% |
| 最终 HPWL | 27693.2 um |
| 镜像优化实例数 | 53 |

**子步骤**:
- 3_1 Global Placement (skip IO)
- 3_2 IO Placement
- 3_3 Global Placement
- 3_4 Resize/Repair Timing
- 3_5 Detailed Placement

---

## 4. 时钟树综合（CTS）

**说明**: ALU 为纯组合逻辑，时钟信号无 sink（无寄存器），TritonCTS 检测到 0 个时钟 sink，跳过时钟树插入。布局结果直接传递至布线阶段。

---

## 5. 布线（Routing）

**工具**: OpenROAD (FastRoute + TritonRoute)  

| 指标 | 数值 |
|------|------|
| 布线后面积 | 7779 um² |
| 利用率 | 10% |
| 最终 DRC 违规 | **0** |
| Antenna 违规 | 0 |
| 总 Via 数 | 6771 |
| 布线运行时间 | 3 min 12 s |
| 峰值内存 | 1394 MB |

**Via 分布**:
- li1 → met1: 3286
- met1 → met2: 3226
- met2 → met3: 225
- met3 → met4: 22
- met4 → met5: 12

---

## 6. 版图生成（Finish / GDSII）

**工具**: OpenROAD + KLayout  

| 指标 | 数值 |
|------|------|
| 输出文件 | `6_final.gds` |
| Fill cell 数 | 9128 |
| 总实例数（含 fill） | 11089 |
| 最终面积 | 7779 um² |

---

## 7. PPA 汇总（Post-Route）

### 时序（Timing）

| 指标 | 数值 |
|------|------|
| 时钟周期约束 | 10.0 ns |
| Setup WNS | **+0.749 ns** (无违规) |
| Setup TNS | 0 |
| Hold WNS | +5.028 ns (无违规) |
| Hold TNS | 0 |
| 最大工作频率 (fmax) | **108.1 MHz** |
| Setup 违规数 | 0 |
| Hold 违规数 | 0 |

### 面积（Area）

| 指标 | 数值 |
|------|------|
| Die 面积 | 90000 um² |
| Core 面积 | 77594.4 um² |
| 标准单元面积 | 7778.7 um² |
| 利用率 | **10.0%** |
| 逻辑单元（组合+反相器） | 802 |
| 时序修复 Buffer | 117 |

### 功耗（Power）

| 指标 | 数值 |
|------|------|
| 内部功耗 | 170.5 uW |
| 开关功耗 | 256.4 uW |
| 漏电功耗 | 0.003 uW |
| **总功耗** | **426.9 uW** |

### 电源完整性（IR Drop）

| 网络 | 平均 IR Drop | 最大 IR Drop |
|------|-------------|-------------|
| VDD | 1.14 uV | 8.93 uV |
| VSS | 1.11 uV | 9.18 uV |

---

## 8. 输出文件列表

| 文件 | 描述 |
|------|------|
| `reports/1_2_yosys.log` | Yosys 综合详细日志 |
| `reports/1_synth.log` | OpenROAD 综合后读入日志 |
| `reports/2_1_floorplan.log` | 布图规划日志 |
| `reports/3_3_place_gp.log` | 全局布局日志 |
| `reports/3_5_place_dp.log` | 详细布局日志 |
| `reports/4_1_cts.log` | CTS 日志（无时钟 sink） |
| `reports/5_1_grt.log` | 全局布线日志 |
| `reports/5_2_route.log` | 详细布线日志 |
| `reports/6_report.log` | 最终 PPA 报告日志 |
| `reports/6_report.json` | 最终 PPA 指标（JSON） |
| `reports/6_final_netlist.v` | 后布线门级网表 |
| `reports/6_final.spef` | 寄生参数文件 |
| `results/sky130hd/ALU/base/6_final.gds` | 最终 GDSII 版图（容器内） |
