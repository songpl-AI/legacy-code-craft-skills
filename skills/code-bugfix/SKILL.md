---
name: code-bugfix
description: 根据测试提交的 Bug 报告，自动定位代码、关联归档记录、分析原因并修复。**测试提 Bug 后用它**，**不知道 Bug 在哪个脚本时用它**，**需要关联历史修改记录时用它**。走 code-modify 标准流程修复，完成后自动更新归档修改历史。读取 config/project.yaml 获取项目配置。
allowed-tools: Read Grep Glob Edit Write Bash
---

# code-bugfix

## 输入格式

```bash
# 方式1：传入 Bug 文件路径
/code-bugfix {AGENT_DIR}/{baseDir}/bugs/BUG-20260411-001.md

# 方式2：直接粘贴 Bug 报告内容
/code-bugfix
[粘贴 Bug 报告 Markdown 内容]
```

---

## 执行流程

| Step | 内容 | 详细 |
|------|------|------|
| 1 | 解析 Bug 报告 | 提取 tag、feature、severity、日志 |
| 2 | 关联开发记录 | 三级降级：归档 → 索引 → Grep |
| 3 | 日志分析 | 提取错误信息、函数名、nil 异常 |
| 4 | 读取相关代码 | 定位 bug 位置 |
| 5 | 输出 Bug 分析报告 | 根因、影响范围、修复方案 |
| 6 | 执行修复 | 用户确认后走 code-modify 流程 |
| 7 | 收尾 | 更新 Bug 状态 + 归档历史 |

详细步骤见 `references/` 目录：
- `references/step-1-2.md` — 解析报告 & 关联记录
- `references/step-3-5.md` — 日志分析 & Bug 报告
- `references/step-6-7.md` — 执行修复 & 收尾

---

## 三级降级策略

| 级别 | 来源 | 精度 |
|------|------|------|
| 🟢 1 | 查归档 | 精准，包含修改历史 |
| 🟡 2 | 查脚本索引 | 兜底，快速定位 |
| 🔴 3 | 全量 Grep | 最后手段，需确认 |

---

## 降级处理

以下情况才停下：
- `tag` 字段为空且无法推断 → 询问开发指定功能模块
- 三级搜索全部未命中 → 提示提供脚本路径或关键词
- 日志完全为空 → 请测试重新采集

---

## 使用示例

```bash
/code-bugfix {AGENT_DIR}/{baseDir}/bugs/BUG-20260411-001.md

/code-bugfix
---
tag: moduleName
feature: 功能描述
severity: 一般
---
点击按钮没有反应...
```
