# create - 创建功能归档

> **路径约定**：
> - `{AGENT_DIR}` = `.claude`（Claude Code 配置目录）
> - `{baseDir}` = `project-data`（项目数据目录，来自 `config/project.yaml`）
> - **归档路径** = `.claude/project-data/archive/...`
> - **禁止**写入 skill 自身目录下的 `archive/`

## Step 0 — 提取 TAG 标识

1. 读取目标脚本，查找 `local TAG = "xxx"`
2. 有 TAG → 用 TAG 值作为归档目录名
3. 无 TAG → 用文件名作为归档目录名
4. TAG 是归档的稳定主键，即使脚本 UUID 文件名变更，归档仍然有效

---

## Step 1 — 收集归档信息

询问用户以下信息（如果用户已提供则跳过）：

1. **功能名称**（必填）
   - 简短描述功能
   - 用于文件名，建议 2-6 个字

2. **功能说明**（必填）
   - 业务逻辑描述
   - 用户侧的功能体验

3. **当前负责人**（可选）
   - 默认为当前操作者
   - 格式：姓名

---

## Step 2 — 自动提取技术信息

**从脚本中提取以下内容：**

1. **涉及函数**（主要的）
   - 列出与该功能相关的核心函数
   - 标注主要函数的作用

2. **HTTP 接口**（如有）
   - 列出功能用到的接口
   - 标注接口用途

3. **关键逻辑**
   - 列出核心步骤（3-5步）
   - 描述主要流程

---

## Step 3 — 生成归档文件

**文件路径**：`{AGENT_DIR}/{baseDir}/archive/scripts/{TAG}/功能名称.md`

**文件格式**：
```markdown
# 功能：功能名称

## 基本信息
- **脚本**：scripts/script_name.lua
- **功能创建**：YYYY-MM-DD
- **最后修改**：YYYY-MM-DD
- **当前负责人**：姓名

## 功能说明
[用户提供的业务逻辑描述]

## 核心实现

### 涉及函数
- `FunctionName()` - 函数作用说明

### HTTP 接口
- POST `/v3/module/api` - 接口用途

### 关键逻辑
1. 步骤描述
2. ...

## 修改历史
| 日期 | 开发者 | 修改内容 |
|------|--------|---------|
| YYYY-MM-DD | 姓名 | 初始实现功能名称 |
```

---

## Step 4 — 更新脚本总览

**文件路径**：`{AGENT_DIR}/{baseDir}/archive/scripts/{TAG}/README.md`

**如果文件不存在，创建并写入**：
```markdown
# 脚本：{TAG}

## 基本信息
- **TAG**：{TAG}
- **当前脚本文件**：scripts/script_name.lua
- **功能定位**：[从 script-index.md 读取]
- **代码行数**：约 XXX 行
- **最后更新**：YYYY-MM-DD

## 已归档功能

| 功能 | 负责人 | 最后修改 | 快速链接 |
|------|--------|---------|---------|
| 功能名称 | 姓名 | YYYY-MM-DD | [查看](./功能名称.md) |

## 快速导航
- 功能1：核心函数 `Func1()`，行号 L100-200
- 功能2：核心函数 `Func2()`，行号 L300-400
```

**如果文件已存在，追加新功能到表格**

---

## Step 5 — 更新归档索引

**文件路径**：`{AGENT_DIR}/{baseDir}/archive/index.json`

**格式**：
```json
{
  "lastUpdated": "2026-04-08T12:00:00Z",
  "totalScripts": 10,
  "totalFunctions": 25,
  "scripts": {
    "{{TAG_NAME}}": {
      "name": "功能模块名称",
      "scriptFile": "script_name",
      "functions": ["功能1", "功能2"],
      "lastUpdated": "2026-04-08"
    }
  }
}
```

> **key 使用 TAG**（稳定标识），`scriptFile` 记录当前文件名（可能变更）

---

## Step 6 — 输出归档报告

```markdown
## ✅ 功能归档完成

### 归档信息
- **TAG**：{TAG}
- **脚本**：script_name
- **功能**：功能名称
- **归档路径**：`{AGENT_DIR}/{baseDir}/archive/scripts/{TAG}/功能名称.md`

### 归档内容
- ✅ 涉及函数：N 个
- ✅ HTTP 接口：N 个
- ✅ Watch/Fire 事件：N 个
- ✅ 关键逻辑：N 步
- ✅ 代码位置：已标注

### 查看归档
```bash
/code-archive show {TAG} 功能名称
```

### 下次修改
当其他人修改该脚本时，code-analyze 会自动提示已有归档，避免重复分析。
```

---

## Step 7 — Feedback Loop

归档完成后，输出归档质量询问：

```markdown
---

## 📝 归档质量反馈

本次归档对下次修改有帮助吗？

1. ✅ 有帮助 - 归档准确，下次可以直接参考
2. ⚠️ 一般 - 基本准确，但可以更详细
3. ❌ 没用 - 归档内容有误或不够实用

回复 [1/2/3] 或直接补充说明：
```

**处理用户回复**：

| 回复类型 | 处理方式 |
|---------|---------|
| 回复 1 | 记录到 `archive/index.json` 的 feedback 字段：`{"helpful": true}` |
| 回复 2 | 记录到 feedback 字段：`{"helpful": false, "reason": "需要更详细"}` |
| 回复 3 | 记录到 feedback 字段：`{"helpful": false, "reason": "内容有误"}` |
| 补充说明 | 追加到归档文件的 footer：`---\n**用户反馈**：xxx` |
