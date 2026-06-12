# summary

分析 ORFS 后端实现结果，提取关键 PPA 指标并生成统一格式的芯片性能报告。

## Usage

```
/summary [design_nickname]
```

- `design_nickname` (optional): 设计昵称，如 `tinyRocket`。未指定时从 `get_metrics` 返回数据中自动识别。

---

## 分析流程

### 第一步：收集原始数据

并行读取以下数据源：

**1. PPA 元数据（结构化 JSON）**
```
get_metrics()
```

**2. 时序报告（详细 slack 路径）**
```
read_container_file("/OpenROAD-flow-scripts/flow/reports/sky130hd/<design_nickname>/base/6_finish.rpt")
```

**3. 综合后面积/单元统计**
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/1_1_yosys.log")
```

**4. 布局拥塞报告**
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/3_1_place.log")
```

**5. 布线 DRC 报告**
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/5_2_route.log")
```

**6. 收尾综合报告**
```
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/6_report.log")
```

---

### 第二步：逐项分析

#### 2.1 频率与时序裕量

从 `metadata.json` 提取：

| 字段 | 含义 |
|------|------|
| `finish__timing__setup__ws` | WNS — 最差建立时序裕量（ns），≥ 0 表示无违例 |
| `finish__timing__setup__tns` | TNS — 总负时序裕量（ns），0 表示全部满足 |
| `finish__timing__setup__whs` | WHS — 最差保持时序裕量（ns） |
| `finish__timing__setup__nvp` | 建立违例路径数量 |
| `finish__timing__hold__nvp` | 保持违例路径数量 |

计算可达最高频率：
```
Fmax = 1 / (T_clk - WNS)   [WNS > 0 时]
Fmax = 1 / T_clk            [WNS = 0 时，恰好满足]
```

**评级标准：**
- WNS ≥ 2 ns：时序宽裕，可尝试提频
- 0 ≤ WNS < 2 ns：时序满足，裕量偏小
- WNS < 0：存在时序违例，需修复

#### 2.2 面积

从 `metadata.json` 提取：

| 字段 | 含义 |
|------|------|
| `finish__design__instance__area__stdcell` | 标准单元面积 (µm²) |
| `finish__design__instance__area__macros` | 宏单元面积 (µm²) |
| `finish__design__instance__area` | 总实例面积 (µm²) |
| `finish__design__core__area` | 核心区域总面积 (µm²) |
| `finish__design__instance__count__stdcell` | 标准单元数量 |
| `finish__design__instance__count__macros` | 宏单元数量 |

计算核心利用率：
```
利用率 = 总实例面积 / 核心区域面积 × 100%
```

#### 2.3 拥塞与布局质量

从布局日志中提取：

| 指标 | 来源 | 评级标准 |
|------|------|---------|
| `overflow` | place.log | < 0.1 良好，> 0.2 需调整密度 |
| `HPWL` | place.log | 越小越好，反映布线总长度估计 |
| 全局布线拥塞 GRC | route.log | 0 违例为目标 |
| DRC violations | route.log | 必须为 0 才可流片 |

#### 2.4 布线效率

从 `metadata.json` 提取：

| 字段 | 含义 |
|------|------|
| `route__wirelength__estimated` | 估计布线总长 (µm) |
| `route__drc_errors` | 布线 DRC 错误数 |
| `finish__route__wirelength` | 实际布线总长 (µm) |

布线效率评估：
- DRC errors = 0：布线完全合法
- DRC errors > 0：需检查拥塞热点，考虑降低 `PLACE_DENSITY` 或调整宏摆放

#### 2.5 时钟树与时钟偏斜

从 CTS 日志和 metadata 提取：

| 字段 | 含义 |
|------|------|
| `cts__timing__setup__ws` | CTS 后 WNS |
| `finish__timing__clock__skew` | 最终时钟偏斜 (ns) |
| 时钟缓冲器数量 | CTS 日志中 `Clock buffers` |
| 时钟树深度 | CTS 日志中 `Max level` |

**评级标准：**
- 时钟偏斜 < 10% T_clk：良好
- 时钟偏斜 > 20% T_clk：偏大，可能影响时序裕量

#### 2.6 功耗

从 `metadata.json` 提取：

| 字段 | 含义 |
|------|------|
| `finish__power__internal__total` | 内部功耗 (W) |
| `finish__power__switching__total` | 开关功耗 (W) |
| `finish__power__leakage__total` | 漏电功耗 (W) |
| `finish__power__total` | 总功耗 (W) |

功耗分解：
```
总功耗 = 内部功耗 + 开关功耗 + 漏电功耗
动态功耗 = 内部功耗 + 开关功耗
```

---

### 第三步：生成 PPA 报告

按以下模板输出统一格式报告：

---

## PPA 报告模板

```
╔══════════════════════════════════════════════════════════════╗
║              芯片性能分析报告 (PPA Report)                    ║
╠══════════════════════════════════════════════════════════════╣
║  设计名称  : <DESIGN_NICKNAME>                               ║
║  工艺节点  : SkyWater 130nm (sky130hd)                       ║
║  分析时间  : <DATE>                                          ║
╚══════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【一、频率 & 时序裕量】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  目标时钟周期     : ___ ns  (___ MHz)
  最差建立裕量 WNS : ___ ns  [目标 ≥ 0]
  总负裕量 TNS     : ___ ns  [目标 = 0]
  最差保持裕量 WHS : ___ ns  [目标 ≥ 0]
  建立违例路径数   : ___     [目标 = 0]
  保持违例路径数   : ___     [目标 = 0]
  可达最高频率 Fmax: ___ MHz
  时序状态         : ✓ 满足 / ✗ 违例

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【二、面积】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  核心区域面积     : ___ µm²
  标准单元面积     : ___ µm²
  宏单元面积       : ___ µm²
  总实例面积       : ___ µm²
  核心利用率       : ___%
  标准单元数量     : ___
  宏单元数量       : ___
  触发器数量       : ___

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【三、拥塞 & 布线效率】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  布局 overflow    : ___     [目标 < 0.1]
  全局布线拥塞 GRC : ___     [目标 = 0]
  布线 DRC 错误数  : ___     [目标 = 0]
  实际布线总长     : ___ µm
  布线状态         : ✓ 合法 / ✗ 存在 DRC

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【四、时钟树 & 时钟偏斜】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  时钟偏斜         : ___ ns  [目标 < T_clk × 10%]
  时钟缓冲器数量   : ___
  时序修复缓冲器   : ___
  时钟树深度       : ___

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【五、功耗】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  内部功耗         : ___ mW  (___%)
  开关功耗         : ___ mW  (___%)
  漏电功耗         : ___ mW  (___%)
  动态功耗         : ___ mW
  总功耗           : ___ mW

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
【六、综合评估】
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  时序  : ★★★★★  (WNS=___ ns，Fmax=___ MHz)
  面积  : ★★★★★  (利用率=___%)
  拥塞  : ★★★★★  (DRC=___，overflow=___)
  功耗  : ★★★★★  (总功耗=___ mW)

  优化建议：
  - [ ] （如有时序违例）降低目标频率 或 增大 CORE_UTILIZATION
  - [ ] （如拥塞严重）降低 PLACE_DENSITY 或 调整宏摆放位置
  - [ ] （如功耗偏高）检查时钟门控覆盖率
  - [ ] （如面积偏大）检查综合约束，考虑面积优化选项
```

---

## 评级说明

### 时序评级
| 评级 | 条件 |
|------|------|
| ★★★★★ | WNS ≥ 2 ns，无违例 |
| ★★★★☆ | 0 ≤ WNS < 2 ns，无违例 |
| ★★★☆☆ | WNS < 0，违例路径 ≤ 10 条 |
| ★★☆☆☆ | 违例路径 > 10 条 |
| ★☆☆☆☆ | TNS < -100 ns |

### 面积评级
| 评级 | 条件 |
|------|------|
| ★★★★★ | 利用率 40%~60%（布局余量充足） |
| ★★★★☆ | 利用率 60%~75% |
| ★★★☆☆ | 利用率 75%~85% |
| ★★☆☆☆ | 利用率 > 85%（拥塞风险高） |

### 拥塞评级
| 评级 | 条件 |
|------|------|
| ★★★★★ | DRC = 0，overflow < 0.05 |
| ★★★★☆ | DRC = 0，overflow < 0.1 |
| ★★★☆☆ | DRC = 0，overflow < 0.2 |
| ★★☆☆☆ | DRC > 0 |

---

## 参考

- 完整流程 → `/flow`
- 调试问题 → `/debug`
- ORFS MCP 源码 → `mcp_server/src/index.js`
