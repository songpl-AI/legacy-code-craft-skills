# Lua 调用示例

严格按照 HTTP 请求标准格式生成：

```lua
local TAG = "[{{MODULE_NAME}}]"
local params = {
    key1 = "value1",
    key2 = 123,
}
{{LOG_ERROR}}("[{{CLASS_NAME}}] request params=" .. self.jsonService:encode(params))
self:HttpRequest("{{BASE_URL}}/{{API_PATH}}", params, function(resp)
    -- 成功回调
    {{LOG_ERROR}}("[{{CLASS_NAME}}] resp=" .. tostring(resp))
    if resp and resp ~= "" then
        local msg = nil
        if type(resp) == "string" then
            msg = self.jsonService:decode(resp)
        end
        if msg and msg.code == 0 then
            local data = msg.data
            -- 业务逻辑
            {{LOG_ERROR}}("[{{CLASS_NAME}}] success data.field1=" .. tostring(data.field1))
        else
            {{LOG_ERROR}}("[{{CLASS_NAME}}] failed code=" .. tostring(msg and msg.code) .. " msg=" .. tostring(msg and msg.msg))
        end
    end
end, function(res)
    -- 失败回调（网络错误）
    {{LOG_ERROR}}("[{{CLASS_NAME}}] network error=" .. tostring(res))
    -- 可选：ShowToast 提示用户
end)
```

**调用说明：**
- Mock 模式（`{{MOCK_CONDITION}}`）走 mock 接口
- 真机走正式接口 `{{BASE_URL}}`
