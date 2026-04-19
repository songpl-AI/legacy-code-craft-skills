-- UI 节点绑定模板
-- 适用场景：InitUI() 中绑定 UI 组件
-- 使用前将 {{}} 占位符替换为项目实际值

function {{CLASS_NAME}}:InitUI()
    local root = self:{{FIND_NODE}}("{{NODE_PATH}}")
    local panel = root:Find("Panel_Main")

    -- ===== 单个节点绑定 =====

    -- Button
    self.btnClose = panel:Find("top/Btn_Close")
    if self.btnClose then
        self.btnClose:{{ON_CLICK_ADD}}(function()
            self:OnCloseClick()
        end)
    end

    -- Text
    self.txtTitle = panel:Find("top/Txt_Title")
    if self.txtTitle then
        self.txtTitle:{{SET_TEXT}}("标题文本")
    end

    -- Image
    self.imgIcon = panel:Find("top/Img_Icon")

    -- ===== 循环节点绑定 =====

    -- 按钮数组（Btn_Item_00 ~ Btn_Item_08）
    self.itemButtons = {}
    for i = 0, 8 do
        local idx = string.format("%02d", i)
        local node = panel:Find("list/Btn_Item_" .. idx)
        if node then
            local index = i + 1  -- Lua 数组从 1 开始
            node:{{ON_CLICK_ADD}}(function()
                self:OnItemClick(index)
            end)
            self.itemButtons[index] = node
        end
    end

    -- ===== 节点属性设置 =====
    local panelMain = root:Find("Panel_Main")
    if panelMain then
        panelMain:{{SET_POSITION}}({{POS_X}}, {{POS_Y}})
    end
end

-- ============================================================
-- 占位符说明：
-- {{CLASS_NAME}}           - 类名
-- {{FIND_NODE}}            - 查找节点的方法，如 Find、GetChild
-- {{ON_CLICK_ADD}}         - 添加按钮监听的方法，如 onClick:AddListener
-- {{SET_TEXT}}             - 设置文本的方法，如 .text =、setText
-- {{SET_POSITION}}         - 设置位置的方法，如 SetPosition、setPosition
-- {{POS_X}} / {{POS_Y}}    - 位置坐标值
-- ============================================================

-- 注意事项：
-- 1. Find 前判断父节点是否存在
-- 2. GetComponent 后判断组件是否存在
-- 3. 循环节点统一用数组存储
-- 4. Button onClick 绑定时注意闭包变量（用 local index = i + 1）
