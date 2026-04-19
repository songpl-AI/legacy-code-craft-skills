# Step 1-3: 读取需求 & 索引 & 扫描

> **路径约定**：
> - `{AGENT_DIR}` = `.claude`
> - `{baseDir}` = `project-data`
> - `{SKILL_DIR}` = `.claude/skills`
> - **项目索引** = `.claude/project-data/script-index.md`

## Step 1 — 读取需求文档

根据输入类型自动识别读取方式：

**{{DOC_SYSTEM}} 文档 URL**（包含 `{{DOC_SYSTEM_DOMAIN}}`）：
```bash
SCRIPTS="{SKILL_DIR}/code-req/scripts"
AUTH=$(node -e "const c=require('$SCRIPTS/.yach-config.json'); console.log(c.appkey+':'+c.appsecret)")
{{DOC_SYSTEM}}_AUTH="$AUTH" node "$SCRIPTS/read-doc.js" <URL> | sed 's/!\[图片\](data:image\/[^)]*)/[图片已省略]/g'
```
- 脚本位于 `{SKILL_DIR}/code-req/scripts/read-doc.js`
- 认证信息在 `{SKILL_DIR}/code-req/scripts/.yach-config.json`
- 支持 `/docs/`（输出 markdown）、`/sheets/`（输出表格）等类型
- base64 图片自动过滤，避免内容过大

**本地文件路径**：用 Read 工具读取

**直接粘贴内容**：直接使用

如果内容为空或读取失败 → 告知用户并停止

---

## Step 2 — 读取项目索引

并行读取：
```
{AGENT_DIR}/{baseDir}/script-index.md   — 脚本功能索引
{AGENT_DIR}/{baseDir}/event-index.md    — Watch/Fire 事件索引
```
索引为空时提示用户先运行 `/code-analyze`，但不阻止继续分析（改用 Grep 扫描关键词）。

---

## Step 3 — 代码快速扫描

索引为空或需要补充时，Grep 相关关键词：
- 从需求文档提取业务关键词（功能名、模块名）
- 在 `scripts/` 和 `remoteScripts/` 中搜索相关脚本
- 提取每个相关脚本的 `local TAG`、已有接口、已有事件
