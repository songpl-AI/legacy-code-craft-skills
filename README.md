# Legacy Code Craft Skills

> 老旧游戏项目代码改造工具集，支持 Unity/Unreal/Godot/Lua 脚本，基于 Claude Code Skill 命令

---

## 系统概述

覆盖游戏开发全流程：

| Skill | 用途 |
|-------|------|
| `code-analyze` | 分析脚本结构，自动更新索引 |
| `code-modify` | 安全修改，含风险评估和备份 |
| `code-debug` | 插入/清理调试日志 |
| `code-archive` | 功能归档，沉淀团队知识 |
| `api-search` | 搜索接口文档 |
| `code-bugfix` | Bug 定位与修复 |
| `code-common` | 公共知识管理 |
| `code-req` | 需求分析（策划文档） |

---

## 安装

### 前置条件

已安装 Agent（Claude Code / Codex / Cursor 等）：
```bash
# Claude Code
npm install -g @anthropic-ai/claude-code

# Codex
npm install -g @openai/codex
```

### 一键安装

```bash
bash install.sh /你的项目根目录
# 自动检测 Agent 类型和游戏引擎
# 或手动指定：bash install.sh /项目路径 --agent claude --engine unity
```

**支持的 Agent**：Claude Code (`.claude/`)、Codex (`.codex/`)、Cursor (`.cursor/`)、VS Code (`.vscode/`)

**支持的引擎**：Unity C#、Unreal C++、Godot GDScript、Lua 脚本

---

### 快速接入（新项目 5 分钟上手）

**Step 1：安装**
```bash
cd /Volumes/ExtremeSSD/AIProject/legacy-code-craft-skills
bash install.sh /你的项目根目录
```

安装脚本会：
- 自动检测 Agent 类型（Claude Code / Codex / Cursor 等）
- 自动检测游戏引擎（Unity / Lua / Unreal / Godot）
- 创建 `{AGENT_DIR}/skills/` 和 `{AGENT_DIR}/{BASE_DIR}/` 目录
- 初始化 `script-index.md` 和 `event-index.md` 索引文件
- 可选配置 API Doc Token

**Step 2：重启 Agent**
安装完成后需要重启 Agent（Claude Code / Codex 等）使 skills 生效。

**Step 3：验证安装**
```bash
# 查看已安装的 Skills
/code-analyze

# 或者直接分析一个脚本
/code-analyze scripts/example.lua
```

**Step 4：首次分析（建立索引）**
```bash
# 分析项目中的核心脚本，建立索引
/code-analyze scripts/main.lua
/code-analyze scripts/player.lua
/code-analyze scripts/battle.lua
```

索引建立后，后续修改任何脚本都会自动关联到这些索引。

---

### 引擎切换

如果项目需要切换引擎：
```bash
# 查看当前引擎
cat {AGENT_DIR}/{BASE_DIR}/config/current-engine.txt

# 切换引擎（编辑文件）
echo "unity" > {AGENT_DIR}/{BASE_DIR}/config/current-engine.txt
```

---

### 首次使用配置

**1. API Doc Token（可选，用于 api-search）**

获取 Token：API Doc → 项目 → 设置 → Token配置

创建配置文件：
```bash
cat > {AGENT_DIR}/{BASE_DIR}/api-doc-config.json << EOF
{
  "baseUrl": "https://你的API域名",
  "projectId": "项目ID",
  "token": "你的Token"
}
EOF
```

**2. Bug 提交配置（可选，用于 code-bugfix）**

从 Bug 系统获取配置，放到 `bug-reporter/tb_config.json`。

---

## 快速参考

```bash
/code-analyze 脚本路径              # 分析脚本
/code-modify 脚本路径 需求           # 安全修改
/code-modify 脚本路径 联调 API链接   # 联调接口
/code-debug 脚本路径                # 插入调试日志
/code-debug clean 脚本路径           # 清理调试日志
/code-archive create 脚本路径 功能名  # 归档功能
/api-search 关键词                  # 搜索接口
/code-bugfix Bug文件路径             # Bug 修复
/code-req 策划文档URL                # 需求分析
```

---

## 详细功能说明

### code-analyze — 脚本分析

**不只是分析，是代码认知基础设施**

每次修改陌生脚本前必须使用，防止改错相似代码。

```
/code-analyze scripts/example.lua
/code-analyze scripts/example.lua 某个功能
/code-analyze scripts/example.lua --refresh    # 强制刷新缓存
```

**核心能力**：
- 提取 UI 节点映射表
- 提取 HTTP 接口列表（有无 fail 回调）
- 提取 Watch/Fire 事件列表
- 生成函数调用链（主流程）
- 代码质量问题检测
- **自动维护 script-index.md 和 event-index.md**（全局索引）
- Memory 老化检测（标记 STALE）
- 大文件分函数分析（超过 1000 行）

**回退策略**：当用户提供功能描述而非路径时，按 TAG 匹配索引 → 未命中则全量 Grep

---

### code-modify — 安全修改

**三件事必须做：风险报告 → 备份 → 更新索引**

只新增不修改已有逻辑，如需修改必须生成风险报告并确认。

```
/code-modify scripts/example.lua 添加某个功能
/code-modify scripts/example.lua 联调 https://api.doc/project/123/interface/api/181311
```

**核心流程**：
1. 解析 API Doc 接口（如有 URL）
2. 读取并理解脚本
3. **生成风险报告（必须用户确认）**
4. **备份原文件到 scriptsBackup/**
5. 编写新代码
6. 自检清单
7. **强制更新脚本索引**
8. 提示归档

**API Doc 联调**：提供 URL 时自动解析接口文档（路径、参数、返回值、错误码）

**输出内容**：风险报告 + 修改说明 + 备份路径 + 验证步骤 + **回滚命令**

---

### code-debug — 调试日志

**真机调试的唯一手段**

每次联调接口前用它查响应，每次排查 Bug 前用它定位问题函数。

```
/code-debug 脚本路径
/code-debug 脚本路径 关注的函数或功能
/code-debug clean 脚本路径    # 清除调试日志
```

**添加模式**：
- 自动识别插入点（函数入口、HTTP 请求/回调、Watch/Fire 事件、条件分支、状态切换等）
- **幂等检查**：避免重复叠加调试日志
- 输出插入位置明细

**清除模式**：
- 一键清理 `[DEBUG]` 日志
- **不碰业务日志**：不含 `[DEBUG]` 的 g_LogError 是业务日志，不删除

**日志格式**：`g_LogError("[DEBUG][函数名] 描述" .. tostring(变量))`

---

### code-archive — 功能归档

**团队知识沉淀 + 新人上手文档**

code-modify 完成后用它，团队知识沉淀用它，新人上手用它。

```
/code-archive create scripts/example.lua 功能名称
/code-archive list
/code-archive list {{TAG名}}
/code-archive show {{TAG名}} 功能名称
```

**目录结构**：
```
{AGENT_DIR}/{baseDir}/archive/
├── index.json                         # 快速索引（key 为 TAG）
└── scripts/
    ├── {{TAG_NAME}}/
    │   ├── README.md                  # 该 TAG 下所有功能总览
    │   ├── 功能名称1.md
    │   └── 功能名称2.md
```

**TAG 系统**：跨引擎项目的稳定标识符，即使代码重构也能定位

---

### code-bugfix — Bug 定位与修复

**三级降级定位：归档 → 索引 → Grep**

测试提 Bug 后用它，不知道 Bug 在哪个脚本时用它。

```
/code-bugfix {BUGS_BASE_PATH}/BUG-20260411-001.md
/code-bugfix
---
tag: moduleName
feature: 功能描述
severity: 一般
---
点击按钮没有反应...
```

**三级降级策略**：

| 级别 | 来源 | 精度 |
|------|------|------|
| 🟢 1 | 查归档 | 精准，包含修改历史 |
| 🟡 2 | 查脚本索引 | 兜底，快速定位 |
| 🔴 3 | 全量 Grep | 最后手段，需确认 |

**输出**：根因 + 影响范围 + 修复方案，修复后自动更新归档修改历史

---

### code-req — 需求分析

**策划文档 → 完整开发分析报告**

每次拿到策划文档后用它。

```
/code-req 策划文档URL
/code-req 本地文件路径
/code-req    # 直接粘贴文档内容
```

**输出**：
```
{ANALYSIS_BASE_PATH}/{功能名}_{日期}/
├── 需求分析.md       # 完整分析（内部用）
└── 待确认问题.md     # 可直接发给策划/后端
```

**状态标记**：

| 标记 | 含义 |
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

### code-common — 公共知识管理

**跨模块踩坑沉淀**

创建用它，修改网络/协议/状态机前用它。

```
/code-common create 网络重连机制 "连接断开时，先等待 3 秒再重试"
/code-common list
/code-common search 重连
```

**自动关联**：code-modify 执行时（Step 1 读取脚本后），自动检查是否涉及公共知识模块并提示

**模板库**（`references/templates/`）：
- `http-request.lua` — HTTP 请求模板
- `watch-fire.lua` — Watch/Fire 事件模板
- `ui-binding.lua` — UI 绑定模板
- `exit-cleanup.lua` — Exit 清理模板

**最佳实践**（`references/best-practices/`）：
- `nil-safety.md` — nil 安全处理
- `error-handling.md` — 错误处理规范
- `logging.md` — 日志规范

---

### api-search — 接口文档搜索

**联调前的参数确认**

每次联调接口前用它确认参数格式，每次新增 HTTP 请求时用它获取接口定义。

```
/api-search 关键词
/api-search --refresh   # 强制刷新缓存
/api-search --status    # 查看缓存状态
```

**核心能力**：
- 关键词搜索（中文匹配 title，英文匹配 path）
- 缓存机制（7天有效期）
- 输出：接口参数 + 返回值 + **Lua 调用示例**

---

## 项目结构

> **路径变量说明**：
> - `{AGENT_DIR}` — Agent 配置目录（如 `.claude`、`.codex`、`.cursor`）
> - `{BASE_DIR}` — 项目数据目录，默认 `project-data`（由 install.sh 安装时创建）

```
项目根目录/
├── {AGENT_DIR}/                  # Agent 配置（安装时自动创建）
│   ├── skills/                  # Skills 已安装
│   │   ├── code-analyze/
│   │   ├── code-modify/
│   │   └── ...
│   └── {BASE_DIR}/             # 项目数据（目录名可配置）
│       ├── script-index.md      # 脚本索引（TAG 为主键）
│       ├── event-index.md       # 事件索引（TAG 为主键）
│       ├── config/              # 引擎配置
│       │   ├── unity.yaml
│       │   ├── lua.yaml
│       │   └── current-engine.txt
│       ├── archive/             # 功能归档
│       │   ├── index.json
│       │   └── scripts/
│       │       └── {{TAG_NAME}}/
│       ├── memory/common/       # 公共知识
│       ├── bugs/               # Bug 报告
│       └── api-doc-config.json  # API Doc 配置
└── scriptsBackup/               # 修改备份
```

---

## 引擎配置

引擎配置在 `config/` 目录，每个引擎有独立的解析模式：

| 引擎 | 配置文件 | 说明 |
|------|---------|------|
| Unity | `config/unity.yaml` | C# 类名、Transform、Debug.Log |
| Lua | `config/lua.yaml` | TAG、Watch/Fire、g_LogError |
| Unreal | `config/unreal.yaml` | UCLASS、UE_LOG（预留） |
| Godot | `config/godot.yaml` | $节点、emit_signal（预留） |

切换引擎：修改 `{AGENT_DIR}/{BASE_DIR}/config/current-engine.txt`

---

## 核心亮点

| 亮点 | 说明 |
|------|------|
| **TAG 系统** | 跨引擎/跨文件的稳定标识符 |
| **索引自动维护** | 每次 analyze/modify 后自动更新 script-index.md 和 event-index.md |
| **三级降级定位** | Bug 定位的优雅降级策略（归档 → 索引 → Grep） |
| **幂等调试日志** | 重复插入不污染，清除时只清 `[DEBUG]` 前缀的日志 |
| **回滚机制** | code-modify 提供回滚命令 |
| **code-modify 关联 code-common** | 修改时自动提示踩坑记录 |
| **只新增不修改** | 遵循这一原则保证代码安全 |

---

## 开发规范

### 代码修改原则

1. **只新增代码，不修改已有逻辑**（需修改时先生成风险报告）
2. **修改前必须完整读取目标函数**
3. **每次修改前生成风险报告**

### 引擎特定规范

**Lua**（使用 `config/lua.yaml`）：
```lua
g_LogError("[函数名] 描述" .. tostring(变量))
self:Watch("EVENT", function(key, args)
    local param = args and args[0]
end)
```

**Unity C#**（使用 `config/unity.yaml`）：
```csharp
Debug.LogError($"[{func}] {msg}");
GetComponent<Button>().onClick.AddListener(() => { });
```

---

## Bug 工作流

```
测试提Bug ──────→ 开发收到通知
                     ↓
              /code-bugfix [粘贴MD]
                     ↓
              AI 关联归档 + 定位代码
                     ↓
              确认修复 → code-modify 流程
```

---

## 安装后配置

### API Doc Token（可选）

创建 `{AGENT_DIR}/{BASE_DIR}/api-doc-config.json`：

```json
{
  "baseUrl": "https://api.example.com",
  "projectId": "123",
  "token": "你的Token"
}
```

Token 获取：API Doc → 项目 → 设置 → Token配置

### Bug 提交配置

配置 `bug-reporter/tb_config.json`（从 Bug 系统获取）。

---

版本信息见 `version.json`
