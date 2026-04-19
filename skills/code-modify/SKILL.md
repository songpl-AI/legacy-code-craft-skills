---
name: code-modify
description: 安全修改游戏脚本的标准流程。每次修改前必须使用，确保不破坏已有逻辑。**新增功能用它**，**修复 Bug 用它**，**联调接口用它**。包含：风险报告、备份原文件、自检清单。读取 config/project.yaml 获取项目配置。
allowed-tools: Read Grep Glob Edit Write Bash
---

# code-modify

安全修改脚本的标准流程，确保不破坏已有逻辑。每次修改都使用它。

## 使用方式

```
/code-modify <脚本路径> <需求描述>
/code-modify <脚本路径> 联调 <API Doc URL>
```

---

## 核心流程

```
Step 0 → 解析 API Doc 接口（如有 URL）
Step 1 → 读取并理解脚本
Step 2 → 生成风险报告（必须用户确认）
Step 3 → 备份原文件
Step 4 → 编写代码
Step 5 → 自检清单
Step 6 → 输出修改说明
Step 7 → 强制更新脚本索引（必须）
Step 8 → 提示归档
```

详细执行步骤见 `references/` 目录：

| 文档 | 内容 |
|------|------|
| `references/step-0-api.md` | 解析 API Doc 接口（如有 URL） |
| `references/step-1-2.md` | 读取脚本 + 生成风险报告 |
| `references/step-3-4.md` | 备份 + 编写代码 |
| `references/step-5-6.md` | 自检清单 + 输出修改说明 |
| `references/step-7-8.md` | 更新索引 + 提示归档 |

---

## 快速开始

```bash
# 常规修改
/code-modify scripts/example.lua 添加某个功能

# 联调 API Doc 接口
/code-modify scripts/example.lua 联调 https://{{API_DOC_HOST}}/project/123/interface/api/181311
```

---

## 核心原则

1. **只新增代码，不修改已有逻辑** — 如需修改，必须先生成风险报告并得到确认
2. **修改前必须完整读取目标函数** — 有歧义必须问用户
3. **用户确认后才能继续** — 风险报告是强制门槛

---

## API Doc 联调

如果用户提供了 API Doc URL，自动：
1. 解析接口文档（路径、参数、返回值、错误码）
2. 生成符合 HTTP 请求标准的代码
3. 输出接口解析摘要供用户确认

---

## 输出内容

- 风险报告（修改前）
- 修改说明（修改后）
- 备份路径
- 验证步骤
- 回滚命令

---

**版本**: v2.0 | **更新**: 2026-04-18

> **路径说明**：以下路径由 `config/project.yaml` 配置。
