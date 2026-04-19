-- Watch/Fire 事件模板
-- 适用场景：跨脚本模块通信
-- 使用基类封装的 self:Watch / self:Fire（推荐，无需手动初始化事件服务）

-- ===== Watch 事件（监听） =====

-- 在 initialize() 或 InitUI() 中注册
self:Watch("EVENT_NAME", function(key, args)
    g_LogError("[函数名] Watch EVENT_NAME")

    -- 重要：参数在 args[0]，不要直接用 args
    local param = args and args[0]

    -- nil 安全检查
    if param == nil then
        g_LogError("[函数名] param is nil, skip")
        return
    end

    -- 打印参数（调试用）
    g_LogError("[函数名] param.field=" .. tostring(param.field))

    -- TODO: 处理业务逻辑
    -- self:OnEventHandler(param)
end)

-- ===== Fire 事件（触发） =====

-- 在需要通知其他模块的地方调用
local param = {
    field1 = value1,
    field2 = value2,
}

g_LogError("[函数名] Fire EVENT_NAME param=" .. tostring(param.field1))

self:Fire("EVENT_NAME", param)

-- 注意事项：
-- 1. 事件名全大写下划线，如 HOME_ROOM_JUMP
-- 2. Watch 参数从 args[0] 取，不要直接用 args
-- 3. Watch 注册必须在 initialize() 或 InitUI() 中
-- 4. Fire 可以在任何地方调用
-- 5. 参数打印要 tostring()
-- 6. 修改 Fire 前先查 event-index.md 找到所有 Watch 的脚本

-- 常见事件示例：
-- 事件名全大写下划线，如 GAME_START, LEVEL_UP, DIALOG_SHOW
