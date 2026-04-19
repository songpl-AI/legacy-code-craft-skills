# list 和 show 命令

## list - 列出归档

### 情况 A：列出所有归档

```bash
/code-archive list
```

**输出格式**：
```markdown
## 📚 功能归档列表

**总计**：10 个脚本，25 个功能

### {{MODULE_NAME}} - 功能模块描述
- 功能1（负责人：张三，最后修改：2026-04-05）
- 功能2（负责人：李四，最后修改：2026-04-03）

### {{MODULE_NAME}} - 功能模块描述
- 功能3（负责人：王五，最后修改：2026-04-01）

---

### 查看详情
```bash
/code-archive show TAG名 功能名称
```
```

### 情况 B：列出指定脚本的归档

```bash
/code-archive list {{TAG_NAME}}
```

**输出格式**：
```markdown
## 📚 脚本归档：{{TAG_NAME}}

**脚本名称**：功能模块描述
**代码行数**：约 3000 行
**已归档功能**：3 个

| 功能 | 负责人 | 最后修改 | 核心函数 |
|------|--------|---------|---------|
| 功能1 | 张三 | 2026-04-05 | OnFunc1, Request1 |
| 功能2 | 李四 | 2026-04-03 | OnFunc2, Request2 |
| 功能3 | 王五 | 2026-04-01 | OnFunc3, Init |

---

### 查看详情
```bash
/code-archive show {{TAG_NAME}} 功能名称
```
```

---

## show - 查看功能归档

> **路径约定**：
> - `{AGENT_DIR}` = `.claude`
> - `{baseDir}` = `project-data`
> - **归档路径** = `.claude/project-data/archive/...`

**使用场景**：
- 了解某个功能的实现细节
- 修改功能前查看历史
- 新人快速上手

**执行流程**：

#### Step 1 — 读取归档文件

**文件路径**：`{AGENT_DIR}/{baseDir}/archive/scripts/{TAG}/功能名称.md`

#### Step 2 — 输出归档内容

直接输出归档文件的完整内容

#### Step 3 — 提供后续操作建议

```markdown
---

### 后续操作

**如需修改该功能**：
```bash
/code-modify scripts/script_name.lua 修改某个功能
```

**如需添加调试日志**：
```bash
/code-debug scripts/script_name.lua FunctionName
```

**如需更新归档**：
修改完成后，重新执行 `/code-archive create` 会自动更新归档文件
```
