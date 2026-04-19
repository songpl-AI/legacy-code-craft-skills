---
name: code-req
description: 游戏功能需求分析。**每次拿到策划文档后用它**输出完整开发分析：功能点拆解（客户端/服务器）、工作量估算、接口分析、事件影响链、代码影响分析、风险评估、测试 Checklist。读取 config/project.yaml 获取项目配置。
allowed-tools: Read Grep Glob Write Bash
---

# code-req

> **路径约定**：
> - `{AGENT_DIR}` = `.claude`（Claude Code 配置目录）
> - `{baseDir}` = `project-data`（项目数据目录，来自 `config/project.yaml`）
> - `{SKILL_DIR}` = `.claude/skills`（skill 安装目录）
> - **项目数据路径** = `.claude/project-data/...`
> - **脚本路径** = `.claude/skills/code-req/scripts/...`

## 输入

```
/code-req <文档URL 或 本地文件 或 直接粘贴>
```

---

## 执行流程

| Step | 内容 | 详细 |
|------|------|------|
| 1 | 读取需求文档 | 支持{{DOC_SYSTEM}} URL/本地文件/粘贴 |
| 2 | 读取项目索引 | script-index.md、event-index.md |
| 3 | 代码快速扫描 | Grep 相关关键词 |
| 4 | 提取输出路径 | `{AGENT_DIR}/{baseDir}/analysis/{功能名}_{日期}/` |
| 5 | 生成分析报告 | 8 章节完整输出 |
| 6 | 写入文件 | `需求分析.md` + `待确认问题.md` |

详细步骤见 `references/`：
- `references/step-1-3.md` — 读取需求 & 索引 & 扫描
- `references/step-4-6.md` — 生成报告 & 写入文件
- `references/quality-standards.md` — 状态/风险/工作量标记标准

---

## 输出

```
✅ 需求分析完成
📁 {AGENT_DIR}/{baseDir}/analysis/{功能名}_{日期}/
   ├── 需求分析.md       （完整分析，内部用）
   └── 待确认问题.md     （可直接发给策划/后端）

📋 摘要：
- 功能点：客户端 X 项（🆕X / 🔧X / ✅X），服务器 X 项
- 工作量估算：客户端约 X 天，服务器约 X 天
- 涉及脚本：修改 X 个，新增 X 个
- 风险：🔴 X / 🟡 X / 🟢 X
- 待确认问题：X 项（其中 X 项阻塞开发）
```

---

## {{DOC_SYSTEM}} 文档读取

```bash
# 需要配置 {SKILL_DIR}/code-req/scripts/.yach-config.json
# URL 格式：https://{{DOC_SYSTEM_DOMAIN}}/docs/xxxxx
```

---

## 状态标记

| 状态 | 含义 |
|------|------|
| 🆕 全新 | 代码库中完全没有，从零实现 |
| 🔧 改造 | 现有脚本/接口需要修改或扩展 |
| ✅ 已有 | 代码已实现，无需改动 |

| 工作量 | 估算 |
|--------|------|
| 半天以内 | < 0.5 天 |
| 短期 | 0.5 ~ 2 天 |
| 中期 | 2 ~ 5 天 |
| 长期 | 5+ 天 |

---

## 质量要求

- **宁可多问，不要假设** — 特别是数值边界、周期重置、多端同步
- **待确认问题用非技术语言** — 策划能看懂
- **修改高频函数 → 🔴 高风险**
- **纯新增函数 → 🟢 低风险**
