#!/usr/bin/env node
/**
 * {{DOC_SYSTEM}} document reader
 * 读取文档，输出 Markdown 文本（或表格文本）
 *
 * 用法：
 *   node read-doc.js <fileGuid 或完整文档 URL> [--type md|xlsx|pdf|...]
 *
 * 支持的文档类型及默认导出格式：
 *   文档   (docs)      → md  (也可选 pdf/docx/jpg)
 *   表格   (sheets)    → xlsx
 *   幻灯片 (slides)    → pptx (也可选 pdf)
 *   脑图   (mindmaps)  → xmind (也可选 jpeg)
 *
 * 环境变量：
 *   {{DOC_SYSTEM}}_AUTH=appKey:appSecret
 */

const https  = require("https");
const http   = require("http");
const path   = require("path");
const fs     = require("fs");

// ── 认证 ──────────────────────────────────────────────────────────────────

let APP_KEY, APP_SECRET;

// 1. 优先读取环境变量
if (process.env.{{DOC_SYSTEM}}_AUTH) {
  const parts = process.env.{{DOC_SYSTEM}}_AUTH.split(":");
  APP_KEY    = parts[0];
  APP_SECRET = parts.slice(1).join(":");
} else {
  APP_KEY    = process.env.{{DOC_SYSTEM}}_APP_KEY;
  APP_SECRET = process.env.{{DOC_SYSTEM}}_APP_SECRET;
}

// 2. 环境变量未配置，尝试读取配置文件
if (!APP_KEY || !APP_SECRET) {
  try {
    const configPath = path.join(__dirname, "..", ".yach-config.json");
    const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
    APP_KEY = config.appkey || config.appKey;
    APP_SECRET = config.appsecret || config.appSecret;
  } catch (e) {
    // 配置文件不存在或解析失败，继续下面的错误提示
  }
}

if (!APP_KEY || !APP_SECRET) {
  console.error("[{{DOC_SYSTEM}}] 错误：未配置认证信息。请设置环境变量 {{DOC_SYSTEM}}_AUTH=appKey:appSecret 或在配置文件中配置");
  process.exit(1);
}

const BASE_URL = "https://{{DOC_SYSTEM_API_HOST}}";

// ── 文档类型映射 ──────────────────────────────────────────────────────────
// URL 路径段 → { defaultType, binaryTypes }
const DOC_TYPE_MAP = {
  docs:      { defaultType: "md",    binaryTypes: ["pdf", "docx", "jpg"] },
  sheets:    { defaultType: "xlsx",  binaryTypes: ["xlsx"] },
  slides:    { defaultType: "pptx",  binaryTypes: ["pptx", "pdf"] },
  mindmaps:  { defaultType: "xmind", binaryTypes: ["xmind", "jpeg"] },
};

// ── 工具函数 ──────────────────────────────────────────────────────────────

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }

/** 发 HTTP/HTTPS 请求，自动跟随重定向，返回 { status, headers, body } */
function httpRequest(url, opts = {}, redirectCount = 0) {
  return new Promise((resolve, reject) => {
    if (redirectCount > 10) return reject(new Error("too many redirects"));
    const { method = "GET", headers = {}, body, binary = false } = opts;
    const lib = url.startsWith("https") ? https : http;
    const req = lib.request(url, { method, headers }, (res) => {
      if ([301, 302, 303, 307, 308].includes(res.statusCode) && res.headers.location) {
        return httpRequest(res.headers.location, { method: "GET", headers: {}, binary }, redirectCount + 1)
          .then(resolve).catch(reject);
      }
      const chunks = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", () => {
        const buf = Buffer.concat(chunks);
        if (binary) {
          resolve({ status: res.statusCode, headers: res.headers, body: buf });
        } else {
          const text = buf.toString("utf8");
          try { resolve({ status: res.statusCode, headers: res.headers, body: JSON.parse(text) }); }
          catch { resolve({ status: res.statusCode, headers: res.headers, body: text }); }
        }
      });
    });
    req.on("error", reject);
    req.setTimeout(30000, () => req.destroy(new Error("timeout")));
    if (body) req.write(body);
    req.end();
  });
}

function postJson(url, payload) {
  const body = JSON.stringify(payload);
  return httpRequest(url, {
    method: "POST",
    headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(body) },
    body,
  });
}

// ── 解析输入 ──────────────────────────────────────────────────────────────

/**
 * 从 URL 或裸 GUID 中提取 { fileGuid, docCategory }
 * docCategory: docs | sheets | slides | mindmaps | unknown
 */
function parseInput(input) {
  input = input.trim();
  // 尝试从 URL 里识别类型和 GUID
  const urlMatch = input.match(/\/(docs|sheets|slides|mindmaps)\/([A-Za-z0-9]+)/);
  if (urlMatch) {
    return { fileGuid: urlMatch[2], docCategory: urlMatch[1] };
  }
  // 纯 GUID，类型未知
  const guidMatch = input.match(/^[A-Za-z0-9]{8,}$/);
  if (guidMatch) {
    return { fileGuid: input, docCategory: "docs" }; // 默认当文档
  }
  // 尝试宽松匹配 /docs/GUID
  const looseMatch = input.match(/\/([A-Za-z0-9]{8,})(?:[/?#]|$)/);
  if (looseMatch) {
    return { fileGuid: looseMatch[1], docCategory: "docs" };
  }
  throw new Error(`无法解析 file_guid，请提供文档 URL 或 GUID`);
}

// ── API 步骤 ──────────────────────────────────────────────────────────────

async function getToken() {
  const res = await httpRequest(
    `${BASE_URL}/gettoken?appkey=${encodeURIComponent(APP_KEY)}&appsecret=${encodeURIComponent(APP_SECRET)}`
  );
  if (res.body?.code !== 200) throw new Error(`gettoken failed: ${JSON.stringify(res.body)}`);
  return res.body.obj.access_token;
}

async function createExportTask(token, fileGuid, type) {
  const res = await postJson(`${BASE_URL}/openapi/v2/doc/export/async`, {
    file_guid: fileGuid,
    type,
    access_token: token,
  });
  if (res.body?.code !== 200) throw new Error(`export create failed: ${JSON.stringify(res.body)}`);
  return res.body.obj.task_id;
}

async function pollTask(token, taskId, maxWaitMs = 600000) {
  const deadline = Date.now() + maxWaitMs;
  while (Date.now() < deadline) {
    const res = await httpRequest(
      `${BASE_URL}/openapi/v2/doc/export/async/process?task_id=${taskId}&access_token=${token}`
    );
    const obj = res.body?.obj;
    if (obj?.download_url) return obj.download_url;
    if (obj?.status === 3) throw new Error(`export task failed: ${JSON.stringify(obj)}`);
    process.stderr.write(".");
    await sleep(2000);
  }
  throw new Error("export task timed out");
}

// ── 下载 & 转换 ───────────────────────────────────────────────────────────

async function downloadBinary(url) {
  const res = await httpRequest(url, { binary: true });
  if (!Buffer.isBuffer(res.body)) throw new Error("expected binary buffer");
  return res.body;
}

async function downloadText(url) {
  const res = await httpRequest(url);
  if (typeof res.body === "string") return res.body;
  return JSON.stringify(res.body, null, 2);
}

/** 把 xlsx Buffer 转成可读的 Markdown 表格文本 */
async function xlsxToMarkdown(buf) {
  let XLSX;
  try {
    XLSX = require("xlsx");
  } catch {
    // xlsx 未安装，尝试自动安装
    process.stderr.write("\n[{{DOC_SYSTEM}}] 正在安装 xlsx 依赖...\n");
    const { execSync } = require("child_process");
    execSync("npm install xlsx --no-save", {
      cwd: path.join(__dirname, ".."),
      stdio: "inherit",
    });
    XLSX = require("xlsx");
  }

  const workbook = XLSX.read(buf, { type: "buffer" });
  const result = [];

  for (const sheetName of workbook.SheetNames) {
    result.push(`\n## Sheet: ${sheetName}\n`);
    const sheet = workbook.Sheets[sheetName];
    const rows = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: "" });
    if (!rows.length) { result.push("(空表)\n"); continue; }

    // 生成 Markdown 表格
    const maxCols = Math.max(...rows.map((r) => r.length));
    const header = rows[0];
    // 表头
    result.push("| " + Array.from({ length: maxCols }, (_, i) => String(header[i] ?? "")).join(" | ") + " |");
    result.push("| " + Array(maxCols).fill("---").join(" | ") + " |");
    // 数据行（Excel行号 = i+1，在每行前注释行号方便定位）
    for (let i = 1; i < rows.length; i++) {
      const row = rows[i];
      // 把单元格内换行替换为空格，确保一个Excel行对应一行输出
      const cells = Array.from({ length: maxCols }, (_, j) => String(row[j] ?? "").replace(/\r?\n/g, " "));
      result.push(`[R${i + 1}]| ` + cells.join(" | ") + " |");
    }
    result.push("");
  }

  return result.join("\n");
}

// ── 主函数 ────────────────────────────────────────────────────────────────

async function readDoc(input, overrideType) {
  const { fileGuid, docCategory } = parseInput(input);
  if (!fileGuid) throw new Error("无法解析 file_guid");

  const typeInfo = DOC_TYPE_MAP[docCategory] || DOC_TYPE_MAP["docs"];
  const exportType = overrideType || typeInfo.defaultType;
  const isBinary   = typeInfo.binaryTypes.includes(exportType);

  process.stderr.write(`[{{DOC_SYSTEM}}] guid=${fileGuid} category=${docCategory} type=${exportType} binary=${isBinary}\n`);

  const token  = await getToken();
  process.stderr.write(`[{{DOC_SYSTEM}}] token ok\n`);

  const taskId = await createExportTask(token, fileGuid, exportType);
  process.stderr.write(`[{{DOC_SYSTEM}}] task_id=${taskId} polling`);

  const downloadUrl = await pollTask(token, taskId);
  process.stderr.write(`\n[{{DOC_SYSTEM}}] downloading...\n`);

  // xlsx → Markdown 表格文本
  if (exportType === "xlsx") {
    const buf = await downloadBinary(downloadUrl);
    return await xlsxToMarkdown(buf);
  }

  // 其他二进制类型（pdf/pptx/xmind/jpeg/jpg）→ 提示用户
  if (isBinary && exportType !== "md") {
    const buf = await downloadBinary(downloadUrl);
    // 保存到临时文件并告知路径
    const tmpFile = path.join(require("os").tmpdir(), `{{DOC_SYSTEM}}-export-${fileGuid}.${exportType}`);
    fs.writeFileSync(tmpFile, buf);
    return `[{{DOC_SYSTEM}}] 已导出为 ${exportType} 文件：${tmpFile}\n（共 ${buf.length} 字节）`;
  }

  // 文本类型（md/docx 转 md 等）
  return await downloadText(downloadUrl);
}

module.exports = { readDoc, parseInput, DOC_TYPE_MAP };

// ── CLI 入口 ──────────────────────────────────────────────────────────────

if (require.main === module) {
  const args = process.argv.slice(2);
  if (!args.length) {
    console.error([
      "用法: node read-doc.js <fileGuid 或文档 URL> [--type TYPE]",
      "",
      "支持类型:",
      "  文档   (docs)      → 默认 md  | 可选 pdf docx jpg",
      "  表格   (sheets)    → 默认 xlsx",
      "  幻灯片 (slides)    → 默认 pptx | 可选 pdf",
      "  脑图   (mindmaps)  → 默认 xmind | 可选 jpeg",
    ].join("\n"));
    process.exit(1);
  }

  const input = args[0];
  const typeIdx = args.indexOf("--type");
  const overrideType = typeIdx !== -1 ? args[typeIdx + 1] : undefined;

  readDoc(input, overrideType)
    .then((text) => process.stdout.write(text + "\n"))
    .catch((e) => { console.error("[{{DOC_SYSTEM}}] error:", e.message); process.exit(1); });
}
