# Step 4-5: 更新索引

## Step 4 — 自动更新脚本功能索引（必须执行）

分析完成后，**必须**更新 `{AGENT_DIR}/{baseDir}/script-index.md`：

1. 读取 `{AGENT_DIR}/{baseDir}/script-index.md`
2. 检查当前分析的脚本是否已在索引中（**按 TAG 匹配**，TAG 是第一列）
3. **已存在** → 更新该行的「脚本文件」「功能定位」「关键功能」「核心接口」「最后分析」字段
4. **不存在** → 在 `<!-- INDEX_END -->` 标记**前一行**插入新条目
5. 格式：`| TAG | 脚本文件名前缀（前8位） | 功能定位 | 关键功能（逗号分隔，最多5个） | 核心接口（逗号分隔） | 最后分析 |`

> **TAG 提取规则**：优先用 `local TAG = "xxx"`；无 TAG 变量则用文件名
> **最后分析**：自动填入当前日期，如 `2026-04-18`

示例：
```
| `{{TAG_NAME}}` | `script_abc12345` | 模块功能描述 | 功能1、功能2、接口调用 | `/v3/module/api` | 2026-04-18 |
```

---

## Step 5 — 自动更新事件索引（必须执行）

将本脚本中所有 Watch/Fire 事件写入 `{AGENT_DIR}/{baseDir}/event-index.md`：

1. 读取 `{AGENT_DIR}/{baseDir}/event-index.md`
2. 遍历本脚本中所有 `self:Watch("XXX", ...)` 和 `self:Fire("XXX", ...)` 调用
3. 对每个事件：
   - **已存在同 TAG 同事件的行** → 更新脚本文件名、函数名和参数说明
   - **不存在** → 在 `<!-- EVENT_INDEX_END -->` 标记**前一行**插入新条目
4. 格式：`| 事件名 | Watch/Fire | TAG | 脚本文件前缀 | 所在函数 | 参数说明 |`

> **TAG 提取规则**：同 Step 1，优先用 `local TAG = "xxx"`；无 TAG 则用文件名

示例：
```
| `{{EVENT_NAME}}` | Watch | `{{TAG_NAME}}` | `script_abc12345` | `OnEvent()` | `args[0]` = { key } |
| `{{EVENT_NAME}}` | Fire | `{{TAG_NAME}}` | `script_def67890` | `Submit()` | { id = value } |
```

> 事件索引帮助在修改 Fire 时，快速找到所有 Watch 的脚本，评估影响范围。
