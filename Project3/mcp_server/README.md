# MCP Server — ORFS 自动化工具服务

## 本项目的 MCP Server

本 Server 封装了对 `orfs-agent` Docker 容器的操作，为 Claude Agent 提供数字后端自动化流程（ORFS）的工具调用能力。

### 技术栈

| 组件 | 版本 |
|------|------|
| Node.js | >= 18（ESM） |
| `@modelcontextprotocol/sdk` | ^1.29.0 |
| `zod` | ^4.3.6（参数校验） |

### 安装与启动

```bash
cd mcp_server
npm install
node src/index.js
```

> 通常不需要手动启动，Claude Code 会根据 `.claude/settings.local.json` 中的 MCP 配置自动管理进程。

---

## 工具列表

### `run_stage` — 执行后端流程阶段

在 `orfs-agent` 容器内运行指定的 ORFS make 目标。

| 参数 | 类型 | 说明 |
|------|------|------|
| `stage` | enum | `synth` / `floorplan` / `place` / `cts` / `route` / `finish` |

```json
{ "stage": "synth" }
```

---

### `get_metrics` — 读取 PPA 指标

读取容器内 `metadata.json`，返回综合、时序、面积等全流程指标数据。无需参数。

---

### `read_container_file` — 读取容器内文件

读取容器内任意文件（日志、报告等）。

| 参数 | 类型 | 说明 |
|------|------|------|
| `path` | string | 容器内绝对路径，如 `/OpenROAD-flow-scripts/flow/logs/sky130hd/ALU/1_synth.log` |

---

### `list_files_container` — 浏览容器目录

列出容器内指定目录的文件列表。

| 参数 | 类型 | 说明 |
|------|------|------|
| `path` | string | 容器内目录路径 |

---

### `read_file` — 读取宿主机文件

读取宿主机项目目录下的文件内容（RTL、配置、约束等）。

| 参数 | 类型 | 说明 |
|------|------|------|
| `path` | string | 相对于项目根目录的路径 |

---

### `write_file` — 写入宿主机文件

向宿主机写入或更新文件，目录不存在时自动创建。

| 参数 | 类型 | 说明 |
|------|------|------|
| `path` | string | 目标写入路径 |
| `content` | string | 文件完整内容 |

---

## 与 Claude Code 的集成

MCP Server 在 `.claude/settings.local.json` 中注册：

```json
{
  "mcpServers": {
    "orfs-automation": {
      "command": "node",
      "args": ["mcp_server/src/index.js"]
    }
  }
}
```

Claude Code 启动时会自动以子进程方式运行本 Server，并通过 stdio 进行 JSON-RPC 通信。Agent 在对话中调用工具时，请求会路由到对应的工具处理函数。

---

## 错误处理

所有工具均返回统一结构：

- 成功：`{ content: [{ type: "text", text: "..." }] }`
- 失败：`{ isError: true, content: [{ type: "text", text: "错误信息" }] }`

错误信息包含原始错误和相关日志片段，便于 Agent 诊断并决定下一步操作。
