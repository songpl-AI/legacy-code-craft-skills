---
name: code-archive
description: 功能归档管理。将已实现的功能进行总结归档。**code-modify 完成后用它**，**团队知识沉淀用它**，**新人上手用它**。支持创建归档、查看归档、列表展示。TAG 系统用于跨引擎项目中的稳定标识。读取 config/project.yaml 获取项目配置。
allowed-tools: Read Grep Glob Edit Write Bash
---

# code-archive

将脚本中已实现的功能进行总结归档，方便后续维护和新人快速理解。

## 使用方式

```
/code-archive create <脚本路径> <功能名称>
/code-archive list
/code-archive list <TAG名>
/code-archive show <TAG名> <功能名称>
```

---

## 核心流程

| 命令 | 流程 |
|------|------|
| `create` | Step 0-7（提取 TAG → 收集信息 → 提取技术 → 生成文件 → 更新总览 → 更新索引 → 输出报告 → Feedback Loop） |
| `list` | 列出所有归档或指定 TAG 的归档 |
| `show` | 查看具体功能归档 |

详细步骤见 `references/` 目录：

| 文档 | 内容 |
|------|------|
| `references/create.md` | create 命令完整执行流程 |
| `references/list-show.md` | list 和 show 命令详解 |
| `references/best-practices.md` | 归档最佳实践 |

---

## 快速开始

```bash
# 创建归档
/code-archive create scripts/example.lua 功能名称

# 列出所有归档
/code-archive list

# 查看脚本归档
/code-archive list {{TAG_NAME}}

# 查看功能详情
/code-archive show {{TAG_NAME}} 功能名称
```

---

## 目录结构

> **路径说明**：
> - `{AGENT_DIR}` = `.claude`（Claude Code 的配置目录，对应 Claude Code 项目中的 `.claude/`）
> - `{baseDir}` = `project-data`（项目数据目录，来自 `config/project.yaml` 的 `paths.baseDir`）
>
> **完整归档路径**：`{AGENT_DIR}/{baseDir}/archive/...` = `.claude/project-data/archive/...`
>
> **重要**：归档数据应写入项目目录下的 `.claude/project-data/archive/`，而不是 skill 目录下的 `archive/`。

```
{AGENT_DIR}/{baseDir}/archive/
├── index.json                         # 快速索引（key 为 TAG）
└── scripts/                           # 按 TAG 组织
    ├── {{TAG_NAME}}/
    │   ├── README.md
    │   ├── 功能名称1.md
    │   └── 功能名称2.md
    └── {{TAG_NAME}}/
        ├── README.md
        └── 功能名称.md
```

---

**版本**: v2.0 | **更新**: 2026-04-18
