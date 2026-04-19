-- Exit 清理模板
-- 适用场景：脚本释放时清理资源
-- 使用前将 {{}} 占位符替换为项目实际值

function {{CLASS_NAME}}:Exit()
    -- ===== 1. 停止协程 =====
    -- 根据项目实际调整协程停止方法
    if self.myCoroutine then
        self:{{STOP_COROUTINE}}(self.myCoroutine)
        self.myCoroutine = nil
    end

    -- ===== 2. 停止定时器 =====
    if self.timer then
        self.timer:{{TIMER_STOP}}()
        self.timer = nil
    end

    -- ===== 3. 清理按钮事件监听 =====
    -- 单个按钮
    if self.btnClose then
        self.btnClose:{{ON_CLICK_REMOVE_ALL}}()
    end

    -- 按钮数组
    if self.itemButtons then
        for i = 1, #self.itemButtons do
            if self.itemButtons[i] then
                self.itemButtons[i]:{{ON_CLICK_REMOVE_ALL}}()
            end
        end
    end

    -- ===== 4. 销毁动态创建的节点 =====
    if self.dynamicNode then
        self.dynamicNode:{{DESTROY}}()
        self.dynamicNode = nil
    end

    -- ===== 5. 清理资源引用 =====
    if self.remoteAsset then
        self.remoteAsset = nil
    end

    -- ===== 6. 调用父类 Exit =====
    {{CLASS_NAME}}.super.Exit(self)
end

-- ============================================================
-- 占位符说明：
-- {{CLASS_NAME}}           - 类名
-- {{STOP_COROUTINE}}       - 停止协程的方法，如 StopCoroutineSafely
-- {{TIMER_STOP}}           - 停止定时器的方法，如 Stop
-- {{ON_CLICK_REMOVE_ALL}}  - 移除按钮监听的方法，如 onClick:RemoveAllListeners
-- {{DESTROY}}              - 销毁节点的方法，如 Destroy、DestroyNode
-- ============================================================

-- 必须清理的资源：
-- ✅ 协程（Coroutine）
-- ✅ 定时器（Timer）
-- ✅ 按钮事件监听（onClick）
-- ✅ 动态创建的节点
-- ✅ 资源引用

-- 不需要清理的：
-- ❌ Prefab 中原本就有的节点（不是动态创建的）
-- ❌ 事件监听（部分框架自动清理）
-- ❌ 局部变量（Lua GC 自动回收）

-- 注意事项：
-- 1. 清理顺序：协程 → 定时器 → 事件监听 → 节点 → 父类
-- 2. 清理后置空引用，避免悬空指针
-- 3. 必须调用 super.Exit(self)
