-- HTTP 请求标准模板
-- 适用场景：所有 HTTP 接口调用
-- 使用前将 {{}} 占位符替换为项目实际值

-- ============================================================
-- 请求参数
-- ============================================================
local params = {
    key1 = "value1",
    key2 = 123,
}

-- ============================================================
-- 发送请求
-- ============================================================
-- {{REQUEST_METHOD}}({{API_PATH}}, params, function(resp)
--     -- === 成功回调 ===
--
--     if resp and resp ~= "" then
--         local msg = nil
--
--         -- 解析响应（根据项目实际调整）
--         if type(resp) == "string" then
--             msg = {{JSON_DECODE}}(resp)
--         elseif type(resp) == "table" then
--             msg = resp
--         end
--
--         -- 判断业务成功（{{SUCCESS_CODE_CHECK}}）
--         if msg and msg.{{SUCCESS_FIELD}} == {{SUCCESS_VALUE}} then
--             local data = msg.{{DATA_FIELD}}
--
--             -- === 业务逻辑 ===
--
--         else
--             -- 业务失败
--             {{LOG_ERROR}}("[{{CLASS_NAME}}] failed code=" .. tostring(msg and msg.{{ERROR_FIELD}}))
--         end
--     end
--
-- end, function(res)
--     -- === 失败回调（网络错误）===
--     {{LOG_ERROR}}("[{{CLASS_NAME}}] network error=" .. tostring(res))
-- end)

-- ============================================================
-- 占位符说明：
-- {{REQUEST_METHOD}}    - HTTP请求方法，如 self:HttpRequest、APIBridge.RequestAsync
-- {{API_PATH}}          - API路径，如 /v3/module/api
-- {{CLASS_NAME}}        - 类名，如 ModuleName
-- {{JSON_DECODE}}       - JSON解析方法，如 self.jsonService:decode
-- {{LOG_ERROR}}         - 错误日志函数，如 g_LogError
-- {{SUCCESS_CODE_CHECK}} - 成功码判断，如 msg.code == 0
-- {{SUCCESS_FIELD}}     - 成功码字段，如 code
-- {{SUCCESS_VALUE}}     - 成功码值，如 0
-- {{DATA_FIELD}}        - 数据字段，如 data
-- {{ERROR_FIELD}}       - 错误信息字段，如 msg
-- ============================================================

-- 注意事项：
-- 1. 必须有 fail 回调
-- 2. 所有变量拼接必须 tostring()
-- 3. 字符串连接用 .. 不能用 +
-- 4. 判断成功用 msg.{{SUCCESS_FIELD}} == {{SUCCESS_VALUE}}
