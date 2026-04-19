# 错误处理最佳实践

## 1. HTTP 响应处理

### ✅ 正确写法

```lua
self:HttpRequest(url, params, function(resp)
    -- 1. 检查响应是否为空
    if resp and resp ~= "" then
        local msg = nil

        -- 2. 解析 JSON
        if type(resp) == "string" then
            msg = self.jsonService:decode(resp)
        end

        -- 3. 判断业务成功
        if msg and msg.code == 0 then
            local data = msg.data
            -- 业务逻辑
        else
            -- 4. 业务失败处理
            g_LogError("[Func] failed code=" .. tostring(msg and msg.code))
        end
    end
end, function(res)
    -- 5. 网络错误处理
    g_LogError("[Func] network error=" .. tostring(res))
end)
```

### ❌ 错误写法

```lua
-- 错误1：没有 fail 回调
self:HttpRequest(url, params, function(resp)
    -- 网络错误时什么都不会发生
end)

-- 错误2：用 data.msg 判断成功
if data.msg == "success" then  -- ❌ 不可靠
    -- 应该用 msg.code == 0
end

-- 错误3：不检查 resp 是否为空
local msg = self.jsonService:decode(resp)  -- ❌ resp 可能是 nil
```

---

## 2. nil 安全

### ✅ 正确写法

```lua
-- 使用 and 运算符短路
local code = msg and msg.code
local field = data and data.field

-- 字符串拼接用 tostring()
g_LogError("code=" .. tostring(msg and msg.code))

-- 条件判断
if msg and msg.code == 0 then
    -- 安全
end
```

### ❌ 错误写法

```lua
-- 错误1：直接访问可能为 nil 的字段
local code = msg.code  -- ❌ msg 可能是 nil

-- 错误2：nil 参与字符串连接
g_LogError("code=" .. msg.code)  -- ❌ 如果 msg 是 nil，会报错

-- 错误3：不判断 nil
if msg.code == 0 then  -- ❌ msg 是 nil 时会报错
    -- ...
end
```

---

## 3. 回调函数中的 self

### ✅ 正确写法

```lua
-- 使用闭包，self 正确传递
button.onClick:AddListener(function()
    self:OnClick()  -- ✅ self 指向当前对象
end)

-- HTTP 回调中使用 self
self:HttpRequest(url, params, function(resp)
    self:RefreshUI()  -- ✅ self 可用
end)
```

### ❌ 错误写法

```lua
-- 错误：直接传递方法引用
button.onClick:AddListener(self.OnClick)  -- ❌ self 会丢失
```

---

## 4. 循环中的闭包

### ✅ 正确写法

```lua
for i = 1, 9 do
    local index = i  -- 创建局部变量
    button.onClick:AddListener(function()
        self:OnClick(index)  -- ✅ index 被正确捕获
    end)
end
```

### ❌ 错误写法

```lua
for i = 1, 9 do
    button.onClick:AddListener(function()
        self:OnClick(i)  -- ❌ 所有回调都会使用最后一个 i 的值
    end)
end
```

---

## 5. code != 0 的处理

### ✅ 正确写法

```lua
if msg and msg.code == 0 then
    -- 成功逻辑
else
    -- 失败处理
    g_LogError("[Func] failed code=" .. tostring(msg and msg.code) .. " msg=" .. tostring(msg and msg.msg))

    -- 可选：用户提示
    self.{{EVENT_FIRE_METHOD}}("SHOW_TOAST", {
        content = msg and msg.msg or "操作失败"
    })
end
```

### ❌ 错误写法

```lua
-- 错误1：只处理成功，不处理失败
if msg and msg.code == 0 then
    -- 成功逻辑
end
-- ❌ code != 0 时什么都不做，用户不知道发生了什么

-- 错误2：不打印错误信息
if msg and msg.code ~= 0 then
    return  -- ❌ 没有日志，无法排查问题
end
```

---

## 6. 网络错误处理

### ✅ 正确写法

```lua
self:HttpRequest(url, params, function(resp)
    -- 成功回调
end, function(res)
    -- 网络错误回调
    g_LogError("[Func] network error=" .. tostring(res))

    -- 用户提示
    self.{{EVENT_FIRE_METHOD}}("SHOW_TOAST", {
        content = "网络错误，请稍后重试"
    })
end)
```

### ❌ 错误写法

```lua
-- 错误：没有 fail 回调
self:HttpRequest(url, params, function(resp)
    -- ...
end)
-- ❌ 网络错误时用户不知道发生了什么
```

---

## 核心原则

1. **所有 HTTP 请求必须有 fail 回调**
2. **所有分支都要打印日志**（成功、失败、网络错误）
3. **用 msg.code == 0 判断成功**，不用 data.msg
4. **访问字段前判断 nil**（用 and 运算符）
5. **字符串拼接必须 tostring()**
6. **给用户明确的错误提示**（code != 0 或网络错误时）

---

## 常见错误码

| code | 说明 | 处理方式 |
|------|------|---------|
| 0 | 成功 | 正常处理业务逻辑 |
| 1000 | 参数错误 | 检查请求参数，打印错误信息 |
| 1001 | 未登录 | 提示用户重新登录 |
| 1002 | 权限不足 | 提示用户无权限 |
| 其他 | 业务错误 | 打印 msg.msg，提示用户 |
