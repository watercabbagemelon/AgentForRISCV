# CLAUDE.md

## 项目概述

本项目是一个基于 Claude Code 的 RISC-V 模块 RTL 自动生成 Agent。用户只需输入一句自然语言需求（例如：“请你帮我生成一个 ALU，需要支持 ADD/SUB/AND/OR/XOR/SLT，含 zero 标志位”），Agent 将全自动完成以下任务：

1. 需求理解与澄清  
2. Chisel 源码生成  
3. 使用 sbt 编译生成 FIRRTL  
4. 使用 firtool 转换为 Verilog  
5. 使用 Verilator 进行语法检查（lint）  
6. 自动生成 Testbench  
7. 执行仿真并输出验证报告  

整个过程中，除必要的用户需求澄清外，所有技术步骤均自动执行，无需人工干预。

## 技术栈

| 工具        | 用途                                          | 版本要求            |
|------------|-----------------------------------------------|---------------------|
| Node.js    | 运行 Claude Code                              | ≥ 18.0              |
| Java       | 运行 sbt                                      | ≥ 11                |
| sbt        | 编译 Chisel 项目                              | 最新稳定版          |
| firtool    | FIRRTL → Verilog 转换                         | 最新版              |
| Verilator  | 语法检查与仿真                                | ≥ 4.200             |

## 项目结构

项目根目录应包含以下内容（可根据需要调整）：

根目录/
├── CLAUDE.md # 本文件
├── .claude/ # Claude Code 配置目录
│ ├── skills/ # 技能定义（如 chisel-generator）
│ └── hooks/ # 钩子脚本（如 pre-commit）
├── src/ # Chisel 源码
├── generated/ # 生成的 Verilog 文件
├── testbench/ # 自动生成的 Testbench
├── sim/ # 仿真目录
│ └── logs/ # 仿真日志
└── scripts/ # 辅助脚本（编译、仿真等）

## 工作流程（全自动流水线）

当用户输入需求后，Agent 必须严格按照以下顺序执行，无需人工介入：

### 1. 需求理解与澄清
- 解析用户自然语言，识别模块类型（如 ALU、寄存器文件、译码器等）和功能要求。
- 如果信息不足（如缺少位宽、操作类型等），主动向用户提问澄清。
- 若用户指令明确，直接进入下一步。

### 2. Chisel 源码生成
- 根据需求生成符合 RV32I 接口规范的 Chisel 代码。
- 代码必须放置于 `src/` 目录，文件名以模块名命名为`ALU.scala`。
- 模块接口应遵循标准 RV32I 命名与功能：例如 ALU 包含输入 `a`, `b`，输出 `result`，以及 `zero` 标志等。
- 生成的代码应包含必要的 `import chisel3._` 和 `import chisel3.util._`。

### 3. 编译与转换
- 自动执行 `sbt` 编译生成 FIRRTL 文件（可在项目根目录预先配置好 `build.sbt`）。
- 调用 `firtool` 将 FIRRTL 转换为 Verilog，输出到 `generated/` 目录，命名为 `top.sv`。
- 若编译失败，Agent 应尝试分析错误并修正 Chisel 源码，然后重试，最多 3 次。

### 4. 语法检查
- 使用 `verilator --lint-only generated/*.v` 进行语法检查。
- 若发现错误（ERROR），Agent 必须分析错误并修改 Chisel 源码，重复步骤 2–3 直到无 ERROR。
- 允许 WARNING，但必须在最终报告中说明原因。

### 5. Testbench 生成
- 根据模块功能自动生成对应的 C++/Verilog Testbench（推荐使用 Verilator 驱动）。
- Testbench 应覆盖用户指定的所有功能（如 ALU 的 ADD/SUB/AND/OR/XOR/SLT 操作），并包含多种随机/边界测试。
- Testbench 代码放置在 `testbench/` 目录，命名为 `alu_tb.cpp`。

### 6. 仿真与验证报告
- 自动编译 Testbench 并运行仿真，输出结果到 `sim/logs/sim_result.log`。
- 仿真结果必须包含每个测试用例的详细对比（期望值 vs 实际值）以及通过/失败状态。
- 最终报告必须包含：
  - 总测试数量、通过数量、失败数量
  - 每个测试用例的详细结果（格式参考作业要求）
  - 如果存在 Verilator WARNING，说明原因
- 报告以 Markdown 格式输出，保存在 `sim/logs/validation_report.md`。

## 接口规范（RV32I 对齐）

- 模块名称使用 PascalCase。
- 输入/输出端口命名清晰，符合 RV32I 习惯（如 `io.a`, `io.b`, `io.result`, `io.zero` 等）。
- 若模块需要时钟和复位，应使用标准命名 `clock` 和 `reset`。
- 位宽：默认所有数据路径为 32 位，控制信号为 1 位。

## 自动化辅助机制

### Skills
- 当需要生成 Chisel 代码时，优先使用 `.claude/skills/chisel-generator.md` 中定义的标准流程。
- 当需要生成 Testbench 时，使用 `.claude/skills/testbench-generator.md`。

### Hooks
- 在每次生成之前，触发`.claude/hooks/pre_run_clean.sh`,实现对文件夹的清理，避免路径或者文件名冲突。
- 在将chisel文件转化为verilog文件之后，触发`.claude/hooks/post_verilog_generate.sh`，对其语法进行检查并生成日志。
- 如果对verilog文件的语法检查出错，触发`.claude/hooks/on_lint_fail.sh`，让Agent根据日志改成错误。
- 在 `write_to_file` 操作后自动触发语法检查（如果文件为 `.scala` 或 `.v`）。
- 在提交代码前（如 git commit）自动运行完整流水线，确保输出有效。

### 错误恢复
- 任何步骤失败时，Agent 应首先尝试自动修复（最多 3 次）。
- 若无法修复，应输出清晰的错误信息并暂停，等待用户指示。

## 重要约束

1. **API Key 安全**：不得在代码或日志中暴露 `ANTHROPIC_API_KEY`。
2. **代码原创性**：生成的 Chisel 代码必须符合 RV32I 规范，不得抄袭他人配置。
3. **输出一致性**：最终报告必须包含作业要求的 `sim_result.log` 格式。
4. **权限说明**： 在全部流程中，只可以对ClaudeCode当前目录下的文件进行rm或rm -rf操作，对当前目录之外的文件不允许执行上述删除文件或文件夹操作。
5. **写入文件说明**：当重新生成项目文件时，在`/src`目录中默认覆盖原有的文件，且不要生成重复文件

## 示例用户指令

> 请你帮我生成一个 ALU，需要支持 ADD/SUB/AND/OR/XOR/SLT，含 zero 标志位

Agent 将自动执行上述完整流程，最终输出验证报告和生成的 RTL 文件。
