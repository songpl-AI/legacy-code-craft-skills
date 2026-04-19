# Step 0-1: 缓存检查 + 读取脚本

## Step 0 — 缓存检查（按需加载）

**仅在用户提供了脚本路径时执行**（而非模糊搜索场景）。

1. 读取 `{MEMORY_CACHE_PATH}`（如不存在，跳过）
2. 根据脚本路径计算缓存 key（如 `fsync_1f0f3165`）
3. **检查缓存**：
   - 存在且未过期（7天）→ 直接读取缓存，跳过 Step 1~3
   - 存在但已过期 → 继续分析，覆盖缓存
   - 不存在 → 继续分析，生成新缓存
4. `--refresh` 参数时无视缓存，直接重新分析

**缓存失效机制**：
- code-modify 执行后，相关脚本缓存失效
- code-debug clean 执行后，相关脚本缓存失效

---

## Step 1 — 读取脚本并提取 TAG

完整读取目标脚本，**首先提取 TAG 标识**：
- 查找 `local TAG = "xxx"` → 用 TAG 值作为稳定标识
- 无 TAG 变量 → 用文件名（如 `index.lua`）作为标识
- TAG 用于后续索引更新和归档关联

### UI 节点提取规则

- 查找 `self.xxx = panel:Find("路径")` 或 `xxx:Find("路径")`
- 查找 `GetComponent(typeof(Button|Image|Text|TMP))`
- 识别循环绑定：`for i = 0, 8 do ... Find("Item_" .. i)`

### HTTP 接口提取规则

- 查找 `HttpRequest("URL"` 或 `HttpRequest2("URL"`
- 查找 `APIBridge.RequestAsync`
- 提取 URL、参数、回调函数

### Watch/Fire 事件提取规则

两种写法都需要覆盖：
- `self.{{EVENT_WATCH_METHOD}}("EVENT_NAME"` — 事件服务注册
- `self:Watch("EVENT_NAME"` — 基类方法注册
- `self.{{EVENT_FIRE_METHOD}}("EVENT_NAME"` — 事件服务触发
- `self:Fire("EVENT_NAME"` — 基类方法触发

提取事件名、所在函数、参数格式。两种写法功能等价，都需要纳入事件索引。