# 插入点模板

在以下位置插入调试日志：

## 函数入口
```lua
g_LogError("[DEBUG][函数名] enter, 参数名=" .. tostring(参数))
```

## HTTP 请求发出前
```lua
g_LogError("[DEBUG][函数名] request url=/v3/xxx params=" .. tostring(self.jsonService and self.jsonService:encode(params) or "nil"))
```

## HTTP 成功回调（进入回调时）
```lua
g_LogError("[DEBUG][函数名] resp=" .. tostring(resp))
```

## HTTP 解析后
```lua
g_LogError("[DEBUG][函数名] code=" .. tostring(msg and msg.code) .. " data=" .. tostring(msg and msg.data))
```

## HTTP 失败回调
```lua
g_LogError("[DEBUG][函数名] network error=" .. tostring(res))
```

## Watch 事件触发
```lua
g_LogError("[DEBUG][函数名] Watch EVENT_NAME args[0]=" .. tostring(args and args[0]))
```

## Fire 事件发出
```lua
g_LogError("[DEBUG][函数名] Fire EVENT_NAME param=" .. tostring(param))
```

## 条件分支（if/elseif/else）
```lua
g_LogError("[DEBUG][函数名] branch: 分支描述, 变量=" .. tostring(变量))
```

## 状态切换
```lua
g_LogError("[DEBUG][函数名] state change: 旧状态 -> 新状态")
```

## 循环关键迭代
```lua
-- 重要：循环内只在首次或异常时打印，避免刷屏
if i == 1 or 异常条件 then
    g_LogError("[DEBUG][函数名] loop i=" .. tostring(i) .. " 关键值=" .. tostring(值))
end
```

## 函数返回前
```lua
g_LogError("[DEBUG][函数名] return 返回值描述=" .. tostring(返回值))
```
