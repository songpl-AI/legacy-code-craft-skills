# 日志规范最佳实践

## 日志分类

| 日志类型 | 函数 | 可见范围 | 使用场景 |
|---------|------|---------|---------|
| 普通日志 | `g_Log()` | 编辑器 Console | 开发调试、流程追踪 |
| 错误/调试日志 | `g_LogError()` | **真机** + 编辑器 | **真机调试**、错误排查 |

---

## 1. 普通日志（编辑器可见）

### 格式

```lua
local TAG = "[模块功能名]"
g_Log(TAG, "[函数名] 描述", variable)
```

### 使用场景

- ✅ 开发时的流程追踪
- ✅ 非关键路径的调试信息
- ✅ 仅在编辑器中需要的信息

### 示例

```lua
local TAG = "[助力功能]"

function {{CLASS_NAME}}:OnZhuLiClick()
    g_Log(TAG, "[OnZhuLiClick] 按钮点击", "")

    local mapId = HOME_CONFIG_INFO.MapId
    g_Log(TAG, "[OnZhuLiClick] mapId", mapId)

    self:RequestBoost(mapId)
end
```

---

## 2. 错误/调试日志（真机可见）⭐

### 格式

```lua
g_LogError("[函数名] 描述" .. tostring(variable))
```

### 使用场景（必须使用）

- ✅ HTTP 请求参数
- ✅ HTTP 响应（原始数据）
- ✅ code != 0 的情况
- ✅ 网络错误
- ✅ Watch 事件触发
- ✅ Fire 事件发出
- ✅ 状态切换
- ✅ 关键分支判断
- ✅ **所有真机调试需要的信息**

### 示例

```lua
-- HTTP 请求参数
local params = { mapId = 123 }
g_LogError("[RequestBoost] request params=" .. self.jsonService:encode(params))

-- HTTP 响应
g_LogError("[RequestBoost] resp=" .. tostring(resp))

-- 解析后的数据
g_LogError("[RequestBoost] code=" .. tostring(msg and msg.code) .. " data=" .. tostring(msg and msg.data))

-- 业务失败
g_LogError("[RequestBoost] failed code=" .. tostring(msg and msg.code) .. " msg=" .. tostring(msg and msg.msg))

-- 网络错误
g_LogError("[RequestBoost] network error=" .. tostring(res))

-- Watch 事件
g_LogError("[OnEvent] Watch EVENT_NAME args=" .. tostring(args and args[0]))

-- Fire 事件
g_LogError("[OnClick] Fire EVENT_NAME param=" .. tostring(param))

-- 状态切换
g_LogError("[UpdateState] state change: " .. tostring(oldState) .. " -> " .. tostring(newState))

-- 关键分支
g_LogError("[ProcessData] branch: isOwner=" .. tostring(isOwner))
```

---

## 3. 关键路径日志清单

### HTTP 请求流程

```lua
-- ✅ 1. 发请求前
g_LogError("[Func] request params=" .. self.jsonService:encode(params))

self:HttpRequest(url, params, function(resp)
    -- ✅ 2. 收到响应
    g_LogError("[Func] resp=" .. tostring(resp))

    if resp and resp ~= "" then
        local msg = self.jsonService:decode(resp)

        if msg and msg.code == 0 then
            -- ✅ 3. 成功
            g_LogError("[Func] success")
        else
            -- ✅ 4. 业务失败
            g_LogError("[Func] failed code=" .. tostring(msg and msg.code) .. " msg=" .. tostring(msg and msg.msg))
        end
    end
end, function(res)
    -- ✅ 5. 网络错误
    g_LogError("[Func] network error=" .. tostring(res))
end)
```

### Watch/Fire 事件流程

```lua
-- ✅ Watch 触发
self.{{EVENT_}}:Watch("EVENT_NAME", function(key, args)
    g_LogError("[Func] Watch EVENT_NAME args=" .. tostring(args and args[0]))
    -- ...
end)

-- ✅ Fire 发出
g_LogError("[Func] Fire EVENT_NAME param=" .. tostring(param))
self.{{EVENT_}}:Fire("EVENT_NAME", param)
```

---

## 4. 日志格式规范

### 函数名标注

- ✅ 使用 `[函数名]` 前缀
- ✅ 便于搜索和定位

```lua
g_LogError("[OnZhuLiClick] ...")
g_LogError("[RequestBoost] ...")
g_LogError("[RefreshUI] ...")
```

### 变量打印

- ✅ 必须 `tostring()` 包裹
- ✅ 字符串连接用 `..`
- ✅ Table 用 `jsonService:encode()` 或 `tostring()`

```lua
-- ✅ 正确
g_LogError("[Func] count=" .. tostring(count))
g_LogError("[Func] params=" .. self.jsonService:encode(params))
g_LogError("[Func] data=" .. tostring(data))

-- ❌ 错误
g_LogError("[Func] count=" .. count)  -- count 可能是 nil
g_LogError("[Func] count=" + count)   -- Lua 用 .. 不用 +
```

---

## 5. 日志密度控制

### 循环内日志

```lua
-- ✅ 正确：控制密度
for i = 1, count do
    if i == 1 or 异常条件 then
        g_LogError("[Func] loop i=" .. tostring(i) .. " val=" .. tostring(val))
    end
    -- ...
end

-- ❌ 错误：刷屏
for i = 1, 1000 do
    g_LogError("[Func] loop i=" .. tostring(i))  -- 真机日志会刷屏
end
```

### 高频回调

```lua
-- Tick/Update 等高频函数，避免每帧都打日志
function {{CLASS_NAME}}:Tick()
    -- ❌ 错误：每帧都打
    -- g_LogError("[Tick] called")

    -- ✅ 正确：只在必要时打
    if self.needLog then
        g_LogError("[Tick] important event")
        self.needLog = false
    end
end
```

---

## 6. 调试日志标记

### [DEBUG] 标记

用于临时调试的日志，调试完成后统一清理：

```lua
g_LogError("[DEBUG][RefreshProgress] enter, currentPoints=" .. tostring(currentPoints))
g_LogError("[DEBUG][RefreshProgress] fillAmount=" .. tostring(fillAmount))
```

使用 `/code-debug clean` 可一键清理所有 `[DEBUG]` 日志。

---

## 7. 真机查看日志

### 搜索关键字

```bash
# 搜索函数名
grep "OnZhuLiClick" log.txt

# 搜索模块名
grep "助力功能" log.txt

# 搜索 DEBUG 日志
grep "[DEBUG]" log.txt

# 搜索错误
grep "failed" log.txt
grep "error" log.txt
```

---

## 核心原则

1. **真机调试必须用 `g_LogError`**
2. **关键路径必须有日志**（HTTP/事件/状态）
3. **所有日志必须 `tostring()`**
4. **函数名用 `[函数名]` 标注**
5. **循环内控制日志密度**
6. **调试日志带 `[DEBUG]` 标记**

---

## 日志检查清单

- [ ] HTTP 请求前打印参数
- [ ] HTTP 响应后打印原始数据
- [ ] code != 0 打印错误码和消息
- [ ] 网络错误打印错误信息
- [ ] Watch 事件打印参数
- [ ] Fire 事件打印参数
- [ ] 状态切换打印前后状态
- [ ] 所有 tostring() 包裹
- [ ] 循环内控制密度
- [ ] 调试完成后清理 [DEBUG] 日志
