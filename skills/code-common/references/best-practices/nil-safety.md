# nil 安全检查最佳实践

## 核心原则

**Lua 中 nil 参与运算会报错，必须做安全检查。**

---

## 1. 访问字段前判断

### ✅ 正确写法

```lua
-- 使用 and 运算符短路
local code = msg and msg.code

-- 嵌套字段
local value = data and data.field and data.field.subfield

-- 条件判断
if msg and msg.code == 0 then
    -- 安全
end
```

### ❌ 错误写法

```lua
-- 直接访问
local code = msg.code  -- ❌ msg 可能是 nil，会报错

-- 嵌套字段直接访问
local value = data.field.subfield  -- ❌ data 或 field 可能是 nil
```

---

## 2. 字符串拼接

### ✅ 正确写法

```lua
-- 必须 tostring() 包裹
g_LogError("code=" .. tostring(code))
g_LogError("msg=" .. tostring(msg and msg.msg))

-- 复杂拼接
g_LogError("[Func] code=" .. tostring(msg and msg.code) .. " data=" .. tostring(data))
```

### ❌ 错误写法

```lua
-- 直接拼接
g_LogError("code=" .. code)  -- ❌ code 是 nil 时会报错
g_LogError("code=" .. msg.code)  -- ❌ msg 是 nil 时会报错

-- 用 + 连接
g_LogError("code=" + code)  -- ❌ Lua 中字符串连接用 ..
```

---

## 3. 函数参数检查

### ✅ 正确写法

```lua
function {{CLASS_NAME}}:ProcessData(data)
    -- 入口检查
    if data == nil then
        g_LogError("[ProcessData] data is nil, skip")
        return
    end

    -- 继续处理
    local field = data.field
end

-- 或者使用 and 运算符
function {{CLASS_NAME}}:ProcessData(data)
    local field = data and data.field
    if field == nil then
        return
    end
    -- ...
end
```

### ❌ 错误写法

```lua
function {{CLASS_NAME}}:ProcessData(data)
    -- 不检查直接使用
    local field = data.field  -- ❌ data 可能是 nil
end
```

---

## 4. Watch 事件参数

### ✅ 正确写法

```lua
self.{{EVENT_WATCH_METHOD}}("EVENT_NAME", function(key, args)
    -- args[0] 才是真正的参数
    local param = args and args[0]

    -- nil 检查
    if param == nil then
        g_LogError("[Func] param is nil, skip")
        return
    end

    -- 使用参数
    local field = param.field
end)
```

### ❌ 错误写法

```lua
self.{{EVENT_WATCH_METHOD}}("EVENT_NAME", function(key, args)
    -- 错误1：直接用 args
    local param = args  -- ❌ 应该用 args[0]

    -- 错误2：不判断 nil
    local field = param.field  -- ❌ param 可能是 nil
end)
```

---

## 5. 数组/Table 访问

### ✅ 正确写法

```lua
-- 判断 table 是否存在
if self.itemList and #self.itemList > 0 then
    for i = 1, #self.itemList do
        local item = self.itemList[i]
        -- 使用 item
    end
end

-- 访问 table 字段
local value = self.config and self.config["key"]
```

### ❌ 错误写法

```lua
-- 不判断直接遍历
for i = 1, #self.itemList do  -- ❌ itemList 可能是 nil
    -- ...
end

-- 直接访问字段
local value = self.config["key"]  -- ❌ config 可能是 nil
```

---

## 6. 默认值处理

### ✅ 正确写法

```lua
-- 使用 or 提供默认值
local count = data and data.count or 0
local name = user and user.name or "未知"

-- 条件赋值
local value = nil
if data and data.field then
    value = data.field
else
    value = "default"
end
```

### ❌ 错误写法

```lua
-- 直接使用可能为 nil 的值
local count = data.count  -- ❌ data 或 data.count 可能是 nil
```

---

## 7. HTTP 响应解析

### ✅ 正确写法

```lua
self:HttpRequest(url, params, function(resp)
    -- 1. 检查 resp
    if resp and resp ~= "" then
        local msg = nil

        -- 2. 解析前判断类型
        if type(resp) == "string" then
            msg = self.jsonService:decode(resp)
        elseif type(resp) == "table" then
            msg = resp
        end

        -- 3. 使用前判断 msg
        if msg and msg.code == 0 then
            -- 4. 访问 data 前判断
            local data = msg.data
            if data then
                local field = data.field
                -- 使用 field
            end
        end
    end
end)
```

### ❌ 错误写法

```lua
self:HttpRequest(url, params, function(resp)
    -- 不检查直接解析
    local msg = self.jsonService:decode(resp)  -- ❌ resp 可能是 nil

    -- 不检查直接使用
    if msg.code == 0 then  -- ❌ msg 可能是 nil
        local field = msg.data.field  -- ❌ data 可能是 nil
    end
end)
```

---

## 8. UI 节点检查

### ✅ 正确写法

```lua
function {{CLASS_NAME}}:InitUI()
    local root = self.VisElement.transform:Find("路径")
    if not root then
        g_LogError("[InitUI] root not found")
        return
    end

    local panel = root:Find("Panel_Main")
    if not panel then
        g_LogError("[InitUI] panel not found")
        return
    end

    -- 使用 panel
end
```

### ❌ 错误写法

```lua
function {{CLASS_NAME}}:InitUI()
    local root = self.VisElement.transform:Find("路径")
    local panel = root:Find("Panel_Main")  -- ❌ root 可能是 nil
end
```

---

## 常见 nil 错误

| 错误信息 | 原因 | 解决方法 |
|---------|------|---------|
| `attempt to index a nil value` | 访问 nil 的字段 | 使用 `and` 运算符 |
| `attempt to concatenate a nil value` | nil 参与字符串连接 | 使用 `tostring()` |
| `attempt to call a nil value` | 调用 nil 函数 | 检查函数是否存在 |
| `attempt to perform arithmetic on a nil value` | nil 参与数学运算 | 检查变量是否为 nil |

---

## 核心检查清单

- [ ] HTTP 响应检查 `resp and resp ~= ""`
- [ ] JSON 解析后检查 `msg and msg.code`
- [ ] 字段访问用 `and` 运算符
- [ ] 字符串拼接用 `tostring()`
- [ ] Watch 参数用 `args[0]` 并检查 nil
- [ ] UI 节点 Find 后检查是否存在
- [ ] 函数参数入口检查 nil
- [ ] 数组遍历前检查是否存在

---

## 快速排查

当遇到 nil 错误时：

1. **看错误行号** - 定位出错位置
2. **看错误类型** - index/concatenate/call/arithmetic
3. **看变量来源** - HTTP响应/参数/配置/UI节点
4. **加 nil 检查** - 使用 and/if/tostring
5. **加日志** - 打印变量值，确认何时为 nil
