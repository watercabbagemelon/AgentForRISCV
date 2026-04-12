import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { execSync } from "child_process";
import fs from "fs";
import path from "path";

// --- 配置区 ---
const CONTAINER_NAME = "orfs-agent";
const ORFS_FLOW_DIR = "/OpenROAD-flow-scripts/flow";

// 1. 初始化服务器
const server = new McpServer({
  name: "orfs-automation-advanced-server",
  version: "1.1.0",
});

/**
 * 工具 1: 运行后端流程阶段 (run_stage)
 * 使用新版三参数签名：(name, parameters, handler)
 */
server.tool(
  "run_stage",
  {
    stage: z.enum(["synth", "floorplan", "place", "cts", "route", "finish"])
      .describe("要运行的后端流程阶段名称")
  },
  async ({ stage }) => {
    try {
      console.error(`[INFO] 正在运行阶段: ${stage}...`);
      const cmd = `docker exec ${CONTAINER_NAME} bash -c "cd ${ORFS_FLOW_DIR} && make DESIGN_CONFIG=/workspace/config.mk ${stage}"`;
      const output = execSync(cmd, { encoding: "utf-8" });
      return {
        content: [{ type: "text", text: `阶段 ${stage} 执行成功！\n\n日志摘要:\n${output.slice(-800)}` }],
      };
    } catch (error) {
      return {
        isError: true,
        content: [{ type: "text", text: `阶段 ${stage} 运行失败: ${error.message}\n错误日志:\n${error.stdout?.slice(-1000)}` }],
      };
    }
  }
);

/**
 * 工具 2: 获取 PPA 关键指标 (get_metrics)
 */
server.tool(
  "get_metrics",
  {}, // 无参数
  async () => {
    try {
      const cmd = `docker exec ${CONTAINER_NAME} cat ${ORFS_FLOW_DIR}/metadata.json`;
      const output = execSync(cmd, { encoding: "utf-8" });
      return { content: [{ type: "text", text: `当前全流程指标数据 (Metadata):\n${output}` }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: "读取指标失败，请确认是否已生成 metadata.json。" }] };
    }
  }
);

/**
 * 工具 3: 读取容器内部文件 (read_container_file)
 */
server.tool(
  "read_container_file",
  {
    path: z.string().describe("容器内部的绝对路径，用于读取日志或报告")
  },
  async ({ path: containerPath }) => {
    try {
      const cmd = `docker exec ${CONTAINER_NAME} cat "${containerPath}"`;
      const output = execSync(cmd, { encoding: "utf-8" });
      return { content: [{ type: "text", text: output }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `读取容器文件失败: ${error.message}` }] };
    }
  }
);

/**
 * 工具 4: 浏览容器内部目录 (list_files_container)
 */
server.tool(
  "list_files_container",
  {
    path: z.string().describe("容器内部的文件夹路径")
  },
  async ({ path: containerPath }) => {
    try {
      const cmd = `docker exec ${CONTAINER_NAME} ls -F "${containerPath}"`;
      const output = execSync(cmd, { encoding: "utf-8" });
      return { content: [{ type: "text", text: `目录 [${containerPath}] 内容:\n${output}` }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `列出目录失败: ${error.message}` }] };
    }
  }
);

/**
 * 工具 5: 读写宿主机上的设计文件 (read_file / write_file)
 */
server.tool(
  "read_file",
  {
    path: z.string().describe("项目根目录下的文件路径")
  },
  async ({ path: filePath }) => {
    try {
      const content = fs.readFileSync(path.resolve(filePath), "utf-8");
      return { content: [{ type: "text", text: content }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `读取失败: ${error.message}` }] };
    }
  }
);

server.tool(
  "write_file",
  {
    path: z.string().describe("宿主机上的目标写入路径"),
    content: z.string().describe("要写入的文件完整内容")
  },
  async ({ path: filePath, content }) => {
    try {
      const fullPath = path.resolve(filePath);
      const dir = path.dirname(fullPath);
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
      fs.writeFileSync(fullPath, content, "utf-8");
      return { content: [{ type: "text", text: `成功更新文件: ${filePath}` }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `写入失败: ${error.message}` }] };
    }
  }
);

// 连接传输层并启动
const transport = new StdioServerTransport();
await server.connect(transport);