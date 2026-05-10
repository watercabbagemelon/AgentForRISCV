import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { execSync } from "child_process";
import fs from "fs";
import path from "path";

// --- 配置区 ---
const CONTAINER_NAME = "chipyard-agent";
const CHIPYARD_DIR   = "/workspace/chipyard";
const CONDA_ENV      = `${CHIPYARD_DIR}/.conda-env`;
// 宿主机项目根目录（mcp_server/src/ 的上上级）
const PROJECT_ROOT   = path.resolve(new URL("../../", import.meta.url).pathname);
const PERSIST_DIR    = path.join(PROJECT_ROOT, "persist");
const RTL_OUTPUT_DIR = path.join(PERSIST_DIR, "rtl_output");

// conda 激活前缀，所有容器内命令都需要带上
const CONDA_INIT = [
  `source ${CONDA_ENV}/etc/profile.d/conda.sh`,
  `conda activate ${CONDA_ENV}`,
].join(" && ");

// 1. 初始化服务器
const server = new McpServer({
  name: "chipyard-automation-server",
  version: "1.0.0",
});

// ─────────────────────────────────────────────
// 工具 1: 启动 ChipYard 容器 (start_chipyard)
// ─────────────────────────────────────────────
server.tool(
  "start_chipyard",
  {
    image: z.string()
      .default("ictmrc/chipyard-image:1.9.1-ubuntu-22.04")
      .describe("ChipYard Docker 镜像名，默认 ictmrc/chipyard-image:1.9.1-ubuntu-22.04"),
  },
  async ({ image }) => {
    try {
      // 若容器已存在则先删除
      try {
        execSync(`docker rm -f ${CONTAINER_NAME}`, { encoding: "utf-8" });
      } catch (_) { /* 容器不存在时忽略 */ }

      const cmd = [
        "docker run -d",
        `--name ${CONTAINER_NAME}`,
        `-v "${PERSIST_DIR}:/workspace/persist"`,
        image,
        "sleep infinity",
      ].join(" ");

      execSync(cmd, { encoding: "utf-8" });
      return { content: [{ type: "text", text: `容器 ${CONTAINER_NAME} 已启动，镜像: ${image}` }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `启动容器失败: ${error.message}` }] };
    }
  }
);

// ─────────────────────────────────────────────
// 工具 2: 生成 RTL (generate_rtl)
// ─────────────────────────────────────────────
server.tool(
  "generate_rtl",
  {
    config: z.string()
      .describe("ChipYard 设计配置名，如 TinyRocketConfig、MediumBoomConfig 等"),
    extra_make_args: z.string()
      .default("")
      .describe("附加的 make 参数，如 'ROCKETCHIP_ADDONS=...'，可留空"),
  },
  async ({ config, extra_make_args }) => {
    try {
      console.error(`[INFO] 开始生成 RTL，CONFIG=${config} ...`);

      const makeCmd = [
        `cd ${CHIPYARD_DIR}/sims/verilator`,
        `make verilog CONFIG=${config}${extra_make_args ? " " + extra_make_args : ""}`,
        // 将生成结果复制到 persist
        `mkdir -p /workspace/persist/rtl_output`,
        `cp -r generated-src/chipyard.TestHarness.${config} /workspace/persist/rtl_output/`,
      ].join(" && ");

      const cmd = `docker exec ${CONTAINER_NAME} bash -lc "${CONDA_INIT} && ${makeCmd}"`;
      const output = execSync(cmd, { encoding: "utf-8", timeout: 1800000 }); // 30min

      return {
        content: [{
          type: "text",
          text: `RTL 生成成功！CONFIG=${config}\n输出目录: persist/rtl_output/chipyard.TestHarness.${config}/\n\n日志摘要:\n${output.slice(-1000)}`,
        }],
      };
    } catch (error) {
      return {
        isError: true,
        content: [{
          type: "text",
          text: `RTL 生成失败 (CONFIG=${config}): ${error.message}\n错误日志:\n${error.stdout?.slice(-1500)}`,
        }],
      };
    }
  }
);

// ─────────────────────────────────────────────
// 工具 3: 解析 mems.conf，返回 SRAM 黑盒列表 (read_mems_conf)
// ─────────────────────────────────────────────
server.tool(
  "read_mems_conf",
  {
    config: z.string()
      .describe("ChipYard 设计配置名，与 generate_rtl 保持一致"),
  },
  async ({ config }) => {
    try {
      // mems.conf 路径：persist/rtl_output/<config>/<config>.mems.conf
      const confDir = path.join(RTL_OUTPUT_DIR, `chipyard.TestHarness.${config}`);
      const confFile = path.join(confDir, `chipyard.TestHarness.${config}.mems.conf`);

      if (!fs.existsSync(confFile)) {
        // 尝试在子目录 gen-collateral 中查找
        const alt = path.join(confDir, "gen-collateral", `chipyard.TestHarness.${config}.mems.conf`);
        if (!fs.existsSync(alt)) {
          return { isError: true, content: [{ type: "text", text: `未找到 mems.conf，路径: ${confFile}` }] };
        }
        return parseMems(fs.readFileSync(alt, "utf-8"), config);
      }
      return parseMems(fs.readFileSync(confFile, "utf-8"), config);
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `读取 mems.conf 失败: ${error.message}` }] };
    }
  }
);

/**
 * 解析 mems.conf 格式，返回结构化 SRAM 列表
 * 每行格式：name depth width ports mask_gran
 * 例：data_arrays_0_ext 64 32 mrw 8
 */
function parseMems(raw, config) {
  const srams = [];
  for (const line of raw.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    // FIRRTL mems.conf 格式：
    // name <name> depth <N> width <W> ports <type> [mask_gran <G>]
    const nameM    = trimmed.match(/name\s+(\S+)/);
    const depthM   = trimmed.match(/depth\s+(\d+)/);
    const widthM   = trimmed.match(/width\s+(\d+)/);
    const portsM   = trimmed.match(/ports\s+(\S+)/);
    const maskM    = trimmed.match(/mask_gran\s+(\d+)/);
    if (nameM && depthM && widthM && portsM) {
      srams.push({
        name:      nameM[1],
        depth:     parseInt(depthM[1]),
        width:     parseInt(widthM[1]),
        ports:     portsM[1],
        mask_gran: maskM ? parseInt(maskM[1]) : null,
      });
    }
  }

  const summary = srams.map(s =>
    `  ${s.name}: ${s.depth}×${s.width}, ports=${s.ports}${s.mask_gran ? `, mask_gran=${s.mask_gran}` : ""}`
  ).join("\n");

  return {
    content: [{
      type: "text",
      text: `CONFIG=${config} 共发现 ${srams.length} 个 SRAM 黑盒:\n${summary}\n\n原始 JSON:\n${JSON.stringify(srams, null, 2)}`,
    }],
  };
}

// ─────────────────────────────────────────────
// 工具 4: 列出 RTL 输出目录文件 (list_rtl_files)
// ─────────────────────────────────────────────
server.tool(
  "list_rtl_files",
  {
    config: z.string()
      .describe("ChipYard 设计配置名"),
    subdir: z.string()
      .default("")
      .describe("子目录，如 'gen-collateral'，留空则列出顶层"),
  },
  async ({ config, subdir }) => {
    try {
      const targetDir = path.join(RTL_OUTPUT_DIR, `chipyard.TestHarness.${config}`, subdir);
      if (!fs.existsSync(targetDir)) {
        return { isError: true, content: [{ type: "text", text: `目录不存在: ${targetDir}` }] };
      }
      const files = fs.readdirSync(targetDir);
      return {
        content: [{
          type: "text",
          text: `目录 [persist/rtl_output/chipyard.TestHarness.${config}/${subdir}] 内容:\n${files.join("\n")}`,
        }],
      };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `列出目录失败: ${error.message}` }] };
    }
  }
);

// ─────────────────────────────────────────────
// 工具 5: 读取 RTL 输出文件 (read_rtl_file)
// ─────────────────────────────────────────────
server.tool(
  "read_rtl_file",
  {
    config: z.string()
      .describe("ChipYard 设计配置名"),
    filename: z.string()
      .describe("文件名（含子目录），如 'gen-collateral/RocketTile.sv'"),
  },
  async ({ config, filename }) => {
    try {
      const fullPath = path.resolve(
        RTL_OUTPUT_DIR,
        `chipyard.TestHarness.${config}`,
        filename
      );
      // 路径限制在 RTL_OUTPUT_DIR 内
      if (!fullPath.startsWith(RTL_OUTPUT_DIR)) {
        return { isError: true, content: [{ type: "text", text: `拒绝访问 rtl_output 目录之外的路径` }] };
      }
      const content = fs.readFileSync(fullPath, "utf-8");
      return { content: [{ type: "text", text: content }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `读取文件失败: ${error.message}` }] };
    }
  }
);

// ─────────────────────────────────────────────
// 工具 6: 停止并删除 ChipYard 容器 (stop_chipyard)
// ─────────────────────────────────────────────
server.tool(
  "stop_chipyard",
  {}, // 无参数
  async () => {
    try {
      execSync(`docker rm -f ${CONTAINER_NAME}`, { encoding: "utf-8" });
      return { content: [{ type: "text", text: `容器 ${CONTAINER_NAME} 已停止并删除。` }] };
    } catch (error) {
      return { isError: true, content: [{ type: "text", text: `停止容器失败: ${error.message}` }] };
    }
  }
);

// 连接传输层并启动
const transport = new StdioServerTransport();
await server.connect(transport);
