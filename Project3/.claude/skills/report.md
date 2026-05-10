# report

版图生成完成后，自动收集 PPA 参数，生成编号报告，并交互式引导优化迭代。
每轮优化后重新跑后端流程，新报告与优化日志序号一一对应。

## Usage

```
/report
```

无需参数。自动从 `orfs-agent` MCP 读取最新结果，并扫描 `./result/` 确定当前序号。

---

## 执行流程

### 第一步：确定当前序号

扫描 `./result/` 目录，找出已有的 `report_*.md` 文件，取最大序号 +1 作为本次序号 `N`。
若目录为空，则 `N = 1`。

```
list_files_container 或直接读取宿主机 ./result/ 目录
```

### 第二步：收集 PPA 数据

并行调用以下 MCP 工具：

```
get_metrics()
read_container_file("/OpenROAD-flow-scripts/flow/reports/sky130hd/<design_nickname>/base/6_finish.rpt")
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/6_report.log")
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/3_1_place.log")
read_container_file("/OpenROAD-flow-scripts/flow/logs/sky130hd/<design_nickname>/base/5_2_route.log")
```

### 第三步：生成 report_N.md

将收集到的数据填入报告模板，写入 `./result/report_<N>.md`：

```
write_file("result/report_<N>.md", <报告内容>)
```

报告格式见下方模板。

### 第四步：展示报告并询问优化意向

向用户展示报告摘要，然后询问：

> 以上是本次实现的 PPA 报告（report_\<N\>.md）。
> 是否需要对以下参数进行优化？
>
> 1. **时序**：当前 WNS=___ ns，Fmax=___ MHz
> 2. **面积**：当前利用率=___% ，可调整 CORE_UTILIZATION / PLACE_DENSITY
> 3. **功耗**：当前总功耗=___ mW
> 4. **拥塞**：当前 DRC=___，overflow=___
>
> 请描述优化目标，或回复"不需要优化"结束流程。

### 第五步：记录优化内容（如用户选择优化）

根据用户的优化指令，确定需要修改的参数，**在执行前**创建优化日志：

```
write_file("result/log_<N>.md", <优化日志内容>)
```

日志格式见下方模板。日志序号与本轮报告序号相同（均为 N）。

### 第六步：执行优化并重新跑后端

根据优化类型修改对应文件：

**时序优化（提频）：**
```
read_file("persist/sky130hd/<design_nickname>/constraint.sdc")
write_file("persist/sky130hd/<design_nickname>/constraint.sdc", <新内容>)
```

**面积/拥塞优化：**
```
read_file("persist/sky130hd/<design_nickname>/config.mk")
write_file("persist/sky130hd/<design_nickname>/config.mk", <新内容>)
```

修改后重新部署并运行后端流程（参考 `/flow` 步骤四~五），完成后回到**第一步**，
此时序号自动递增为 N+1，生成新的 `report_<N+1>.md` 和（如继续优化）`log_<N+1>.md`。

---

## report_N.md 模板

```markdown
# PPA Report — <DESIGN_NICKNAME> — #<N>

**生成时间：** <YYYY-MM-DD HH:MM>
**工艺节点：** SkyWater 130nm (sky130hd)
**ChipYard 配置：** <config>

---

## 一、频率 & 时序裕量

| 指标 | 数值 | 目标 | 状态 |
|------|------|------|------|
| 目标时钟周期 | ___ ns | — | — |
| 目标频率 | ___ MHz | — | — |
| WNS（最差建立裕量） | ___ ns | ≥ 0 | ✓/✗ |
| TNS（总负裕量） | ___ ns | = 0 | ✓/✗ |
| WHS（最差保持裕量） | ___ ns | ≥ 0 | ✓/✗ |
| 建立违例路径数 | ___ | = 0 | ✓/✗ |
| **可达最高频率 Fmax** | **___ MHz** | — | — |

## 二、面积

| 指标 | 数值 |
|------|------|
| 核心区域面积 | ___ µm² |
| 标准单元面积 | ___ µm² |
| 宏单元面积 | ___ µm² |
| 核心利用率 | ___% |
| 标准单元数量 | ___ |
| 触发器数量 | ___ |

## 三、拥塞 & 布线

| 指标 | 数值 | 目标 | 状态 |
|------|------|------|------|
| 布局 overflow | ___ | < 0.1 | ✓/✗ |
| 布线 DRC 错误数 | ___ | = 0 | ✓/✗ |
| 实际布线总长 | ___ µm | — | — |

## 四、时钟树

| 指标 | 数值 |
|------|------|
| 时钟偏斜 | ___ ns |
| 时钟缓冲器数量 | ___ |
| 时序修复缓冲器 | ___ |

## 五、功耗

| 指标 | 数值 | 占比 |
|------|------|------|
| 内部功耗 | ___ mW | ___% |
| 开关功耗 | ___ mW | ___% |
| 漏电功耗 | ___ mW | ___% |
| **总功耗** | **___ mW** | 100% |

---

## 综合评估

| 维度 | 评级 | 备注 |
|------|------|------|
| 时序 | ★★★★★ | WNS=___ ns |
| 面积 | ★★★★★ | 利用率=___% |
| 拥塞 | ★★★★★ | DRC=___ |
| 功耗 | ★★★★★ | ___ mW |

> 本报告对应优化日志：`result/log_<N>.md`（如有优化）
```

---

## log_N.md 模板

```markdown
# 优化日志 — <DESIGN_NICKNAME> — #<N>

**记录时间：** <YYYY-MM-DD HH:MM>
**对应报告：** result/report_<N>.md（本轮优化后生成）
**上一轮报告：** result/report_<N-1>.md（优化前基准）

---

## 优化目标

> <用户描述的优化需求>

---

## 参数变更记录

### constraint.sdc 变更（如有）

| 参数 | 优化前 | 优化后 | 说明 |
|------|--------|--------|------|
| 时钟周期 | ___ ns | ___ ns | 目标频率从 ___ MHz → ___ MHz |

### config.mk 变更（如有）

| 参数 | 优化前 | 优化后 | 说明 |
|------|--------|--------|------|
| CORE_UTILIZATION | ___ | ___ | ___ |
| PLACE_DENSITY | ___ | ___ | ___ |
| CORE_ASPECT_RATIO | ___ | ___ | ___ |
| CORE_MARGIN | ___ | ___ | ___ |

### sram_macros.v 变更（如有）

> <描述 SRAM 映射变更内容>

---

## 优化依据

> <说明为何做出上述调整，例如：WNS 裕量充足，尝试将频率从 50MHz 提升至 80MHz>

---

## 预期效果

> <预期优化后的 PPA 变化方向>

---

## 实际效果

> 见 result/report_<N>.md
```

---

## 序号管理规则

- `report_1.md`：第一次版图完成后的初始报告（无对应 log）
- `log_1.md` + `report_2.md`：第一次优化的记录与优化后报告
- `log_2.md` + `report_3.md`：第二次优化的记录与优化后报告
- 以此类推：`log_<N-1>.md` 记录第 N-1 次优化，`report_<N>.md` 是优化后结果

**即：log_x 描述"为了得到 report_{x+1} 做了什么"。**

---

## 参考

- PPA 分析方法 → `/summary`
- 完整流程 → `/flow`
- 调试问题 → `/debug`
