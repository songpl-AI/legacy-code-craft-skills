---
name: code-debug
description: 为游戏脚本插入或清理调试日志。真机调试的手段。**每次联调接口前用它**查响应，**每次排查 Bug 前用它**定位问题函数，**每次事件不触发时用它**追踪参数。一键插入关键路径日志，调试完成后一键清理，不留业务日志。读取 config/{ENGINE}/logging.yaml 获取引擎特定的日志 API。
allowed-tools: Read Grep Glob Edit Write
---

# code-debug

## 输入格式

**添加调试日志：**
```
/code-debug 脚本路径
/code-debug 脚本路径 关注的函数或功能
```

**清除调试日志：**
```
/code-debug clean 脚本路径
```

---

## 模式1：添加调试日志

**执行流程**：

1. **读取脚本** → 识别函数、HTTP、Watch/Fire、状态切换点
2. **幂等检查** → 搜索已有 `[DEBUG]` 日志，避免重复叠加
3. **插入日志** → 在关键路径插入，规则见 `references/insertion-points.md`
4. **输出报告** → 插入位置明细

详细步骤见 `references/add-mode.md`

---

## 模式2：清除调试日志

**执行流程**：

1. **读取脚本** → 定位所有 `[DEBUG]` 行
2. **逐一删除** → 含 `g_LogError("[DEBUG]` 的行
3. **验证** → 搜索确认无残留
4. **输出报告** → 清除数量

详细步骤见 `references/clean-mode.md`

---

## 插入点清单

| 位置 | 模板 |
|------|------|
| 函数入口 | `g_LogError("[DEBUG][函数名] enter, 参数名=" .. tostring(参数))` |
| HTTP 请求前 | `g_LogError("[DEBUG][函数名] request url=/v3/xxx params=" .. tostring(...))` |
| HTTP 回调 | `g_LogError("[DEBUG][函数名] resp=" .. tostring(resp))` |
| HTTP 解析后 | `g_LogError("[DEBUG][函数名] code=" .. tostring(msg and msg.code))` |
| Watch 事件 | `g_LogError("[DEBUG][函数名] Watch EVENT_NAME args[0]=" .. tostring(args[0]))` |
| Fire 事件 | `g_LogError("[DEBUG][函数名] Fire EVENT_NAME param=" .. tostring(param))` |
| 条件分支 | `g_LogError("[DEBUG][函数名] branch: 分支描述, 变量=" .. tostring(变量))` |
| 状态切换 | `g_LogError("[DEBUG][函数名] state change: 旧 -> 新")` |
| 循环迭代 | `if i == 1 or 异常 then g_LogError("[DEBUG]...") end` |
| 函数返回 | `g_LogError("[DEBUG][函数名] return=" .. tostring(ret))` |

完整模板见 `references/insertion-points.md`

---

## 重要规则

1. **`[DEBUG]` 前缀必须**，格式：`g_LogError("[DEBUG][函数名] 描述" .. tostring(变量))`
2. **只用 `..` 拼接**，不能用 `+`
3. **必须 tostring()**，防止 nil 拼接报错
4. **循环内加条件控制**：`i == 1 or 异常` 才打印，避免刷屏
5. **不碰业务日志**：不含 `[DEBUG]` 的 `g_LogError` 是业务日志，不删除

---

## 快速导航

- 添加模式详解：`references/add-mode.md`
- 清除模式详解：`references/clean-mode.md`
- 插入点模板：`references/insertion-points.md`
