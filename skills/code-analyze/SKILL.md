---
name: code-analyze
description: 分析游戏脚本结构，生成模块报告。每次修改陌生代码前必须使用，防止改错相似代码。分析后自动更新脚本索引，支持按需加载（缓存）和老化检测。读取 config/project.yaml 和 config/{ENGINE}/patterns.yaml 获取项目配置。
allowed-tools: Read Grep Glob Edit Write Bash
---

# code-analyze

分析脚本结构，生成完整的模块报告。每次修改陌生脚本前必须使用。

## 使用方式

```
/code-analyze <脚本路径> [分析目标（可选）]
/code-analyze <脚本路径> --refresh    # 强制重新分析，刷新缓存
```

---

## 核心流程

```
Step 0 → 缓存检查（按需加载）
Step 1 → 读取脚本，提取 TAG + UI 节点 + HTTP 接口 + Watch/Fire 事件
Step 2 → 输出分析报告
Step 3 → 定向分析（如有）
Step 4 → 更新脚本功能索引（必须）
Step 5 → 更新事件索引（必须）
Step 6 → 索引一致性自检
Step 7 → Memory 老化检测
Step 8 → 缓存写入
```

详细执行步骤见 `references/` 目录：

| 文档 | 内容 |
|------|------|
| `references/step-0-1.md` | 缓存检查 + 读取脚本 |
| `references/step-2-report.md` | 输出分析报告格式 |
| `references/step-4-5-index.md` | 更新脚本索引和事件索引 |
| `references/step-6-8.md` | 索引自检 + 老化检测 + 缓存写入 |
| `references/fallback.md` | 查找脚本的回退策略 |

---

## 快速开始

```bash
# 完整分析
/code-analyze scripts/example.lua

# 定向分析
/code-analyze scripts/example.lua 某个功能

# 强制刷新缓存
/code-analyze scripts/example.lua --refresh
```

---

## 输出内容

- UI 节点映射表
- HTTP 接口列表（有无 fail 回调）
- Watch/Fire 事件列表
- 函数调用链（主流程）
- 代码质量问题
- 可插入点分析
- Memory 老化检测报告（⚠️ STALE 标记）

---

## 自动维护

> 以下路径相对于 `{AGENT_DIR}/{paths.baseDir}/`，由 install.sh 安装时自动创建。

| 文件 | 说明 |
|------|------|
| `script-index.md` | 脚本功能索引（TAG 为主键） |
| `event-index.md` | 事件依赖索引（TAG 为主键） |
| `memory-cache.json` | 分析缓存（7天有效期） |

---

## 回退策略

当用户提供的是功能描述而非脚本路径时：
1. 查 script-index.md（按 TAG 匹配）
2. 未命中 → 全量 Grep `scripts/` + `remoteScripts/`
3. 找到后执行完整分析，更新索引

---

## 大文件处理

脚本超过 1000 行时：
1. Grep 提取关键函数列表
2. 逐函数分析
3. 报告中只保留核心信息

---

**版本**: v2.0 | **更新**: 2026-04-18
