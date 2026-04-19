---
name: code-common
description: 公共知识管理 - 把跨模块踩过的坑沉淀到 memory/common/。**创建用它**，**修改网络/协议/状态机前用它**。在 code-modify 时自动关联提示，避免重复踩坑。读取 config/project.yaml 获取项目配置。
allowed-tools: Read Grep Glob Edit Write Bash
---

# code-common

把跨模块踩过的坑、隐性知识沉淀到 `{AGENT_DIR}/{baseDir}/memory/common/`，修改时自动关联提示。

## 使用方式

```
/code-common create <模块名> <内容>
/code-common list
/code-common search <关键词>
```

## 项目配置

首次使用需配置 `config/project.yaml`：

```yaml
paths:
  baseDir: "project-data"  # 或你项目的目录名

codeStandards:
  logging:
    error: "g_LogError"      # 项目实际使用的日志函数
    warning: "g_LogWarning"
    info: "g_Log"
```

详细执行步骤见 `references/` 目录：

| 文档 | 内容 |
|------|------|
| `references/commands.md` | create/list/search 执行详解 |
| `references/integration.md` | 与 code-modify 的关联提示机制 |
| `references/templates/` | 代码模板（HTTP、Watch/Fire、UI绑定、Exit清理） |
| `references/best-practices/` | 最佳实践（nil安全、错误处理、日志规范） |
| `references/standards/` | 命名约定 |

---

## 快速开始

```bash
# 创建公共知识
/code-common create 协议层规范 "HTTP 请求必须先检查 magic number"

/code-common create 网络重连机制 "连接断开时，先等待 3 秒再重试"

/# 查看所有
/code-common list

# 搜索
/code-common search 重连
```

---

## 自动关联

在 code-modify 执行时（Step 1 读取脚本后），自动检查是否涉及公共知识模块，并提示：

```
⚠️ 公共知识提醒
该脚本可能涉及 [协议层规范]，memory/common/协议层规范.md 中有相关记录：
> HTTP 请求必须先检查 magic number...
是否查看详情？(y/n)
```

---

## 目录结构

> 由 `config/project.yaml` 配置，路径为 `{AGENT_DIR}/{baseDir}/memory/common/`

```
{AGENT_DIR}/{baseDir}/memory/common/
├── index.json           # 公共知识索引
├── 协议层规范.md
├── 网络重连机制.md
└── 状态机设计规范.md
```

---

**版本**: v2.0 | **更新**: 2026-04-18
