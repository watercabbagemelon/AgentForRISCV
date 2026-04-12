# CLAUDE.md - 后端自动化Agent项目规范

## 项目概述
本项目是一个基于Claude Code的数字后端自动化Agent，用于将RTL设计（ALU）通过OpenROAD Flow Scripts (ORFS) 完成从综合到布局布线的完整后端流程，最终生成GDSII版图及PPA报告。Agent通过MCP Server封装Docker操作，利用Skill编排流程，遵循本文件定义的规则与约定。

## 核心环境
- **工艺平台**：sky130hd（唯一允许的平台）
- **容器镜像**：`openroad/orfs:latest`（内置Yosys、OpenROAD、KLayout及sky130hd平台文件）
- **工作模式**：常驻容器 `orfs-agent`，本地设计目录挂载到容器内 `/workspace`
- **ORFS路径**（容器内）：`/OpenROAD-flow-scripts/flow/`
- **输入设计**：第一次作业中验证通过的ALU（顶层模块名 `alu` 或具体名称，以RTL为准）

## 目录结构约定（宿主机）
项目根目录/
├── .claude/ # Claude Code配置目录
│ ├── CLAUDE.md # 本文件
│ ├── skills/ # Skill定义文件
│ │ └── backend-flow.md
│ └── hooks/ # Hook脚本（可选）
├── design/ # 挂载到容器 /workspace
│ ├── rtl/ # RTL源文件（ALU的.v文件）
│ ├── config.mk # ORFS配置（必须）
│ ├── constraint.sdc # 时序约束（必须）
│ └── outputs/ # Agent运行结果存放（可选，亦可使用ORFS默认输出）
├── mcp-server/ # MCP Server源码
│ ├── package.json
│ ├── index.js # MCP Server入口
│ └── docker-exec.js # Docker exec封装
├── scripts/ # 辅助脚本（如指标提取、错误诊断）
└── reports/ # 汇总报告输出

text

## 容器与挂载规范
- **常驻容器名称**：`orfs-agent`（固定）
- **创建命令**（一次性）：
  ```bash
  docker run -d --name orfs-agent -v $(pwd)/design:/workspace openroad/orfs:latest sleep infinity
交互方式：所有EDA工具调用均通过 docker exec orfs-agent <command> 执行。

工作目录：在容器内执行ORFS命令时，必须先 cd /OpenROAD-flow-scripts/flow。

路径映射：宿主机 ./design/ 下的 config.mk、constraint.sdc、RTL文件需放在正确位置，以便ORFS读取。ORFS默认查找 DESIGN_CONFIG 指向的 .mk 文件，其中 VERILOG_FILES 和 SDC_FILE 应使用容器内绝对路径（如 /workspace/rtl/alu.v）

