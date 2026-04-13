# CLAUDE.md - 数字后端自动化Agent规范

## 项目概述
基于Claude Code的数字后端自动化Agent，将ALU的RTL设计通过OpenROAD Flow Scripts（ORFS）完成综合、布图规划、布局、CTS、布线到GDSII生成的完整后端流程，并输出PPA报告。MCP Server封装Docker操作，Agent通过工具调用编排各阶段流程。

## 核心环境
- **工艺平台**：sky130hd
- **容器镜像**：`openroad/orfs:latest`（含Yosys、OpenROAD、KLayout及sky130hd PDK）
- **常驻容器**：`orfs-agent`，宿主机 `./design/` 挂载至容器 `/workspace/design/`
- **ORFS工作目录**（容器内）：`/OpenROAD-flow-scripts/flow/`
- **顶层模块**：`ALU`，RTL源文件为 `alu.sv`

## 目录结构
```
Project2/
├── CLAUDE.md
├── design/                  # 挂载至容器 /workspace/design
│   ├── rtl/alu.sv           # RTL源文件
│   ├── config.mk            # ORFS流程配置
│   └── constraint.sdc       # 时序约束
├── mcp_server/              # MCP Server（Node.js）
│   ├── src/index.js         # 工具定义与入口
│   └── package.json
├── logs/                    # 各阶段运行日志
├── reports/                 # 各阶段报告及汇总
└── results/                 # 最终输出（GDS、报告）
```

## 容器操作规范
- 容器创建（一次性）：`docker run -d --name orfs-agent -v $(pwd)/design:/workspace/design openroad/orfs:latest sleep infinity`
- 所有EDA命令通过 `docker exec orfs-agent <command>` 执行
- 容器内执行ORFS命令前须切换至 `/OpenROAD-flow-scripts/flow/`
- `config.mk` 中路径使用容器内绝对路径（`/workspace/design/...`）

## 关键配置（config.mk）
| 参数 | 值 |
|------|----|
| DESIGN_NAME | ALU |
| PLATFORM | sky130hd |
| VERILOG_FILES | /workspace/design/rtl/alu.sv |
| SDC_FILE | /workspace/design/constraint.sdc |
| DIE_AREA | 0 0 300 300 um |
| CORE_AREA | 10 10 290 290 um |
| PLACE_DENSITY | 0.3 |

## 流程阶段与命令
| 阶段 | make目标 | 说明 |
|------|----------|------|
| 综合 | `1_synth` | Yosys，ABC speed script |
| 布图规划 | `2_floorplan` | Die/Core定义、PDN生成 |
| 布局 | `3_place` | RePlAce全局 + OpenDP详细 |
| CTS | `4_cts` | 纯组合逻辑无sink，自动跳过 |
| 布线 | `5_route` | FastRoute + TritonRoute |
| 版图生成 | `6_finish` | GDS导出，fill cell插入 |

执行示例：
```bash
docker exec orfs-agent bash -c "cd /OpenROAD-flow-scripts/flow && make DESIGN_CONFIG=/workspace/design/config.mk 6_finish"
```

## 输出规范
- 日志：各阶段日志存入 `logs/`
- 报告：各阶段 `.rpt`、`.json` 存入 `reports/`
- 最终输出：`results/6_final.gds`、`results/summary_report.md`

## MCP Server工具
MCP Server（`mcp_server/src/index.js`）提供以下工具供Agent调用：
- `run_orfs_stage`：执行指定ORFS阶段
- `read_report`：读取指定报告文件内容
- `check_drc`：检查DRC违规
- `get_ppa`：提取PPA指标

## 注意事项
- ALU为纯组合逻辑，无寄存器，CTS阶段检测到0个时钟sink，正常跳过
- 布线完成后DRC违规应为0，否则需排查并修复后重新布线
- 报告中路径引用统一使用宿主机相对路径
