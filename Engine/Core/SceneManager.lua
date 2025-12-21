-- Engine/SceneManager.lua
-- 场景管理器：注册与切换
-- 模块：场景管理器
-- 功能：管理并切换场景，代理更新与绘制
-- 依赖：Engine.Object
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：切换场景时先调用旧场景 leave，再调用新场景 enter；避免在切换过程中做耗时操作（如资源大量加载）。
--
-- 方法：
-- - register(name, scene): 注册场景
-- - switch(name, params): 切换到已注册的场景，传入可选参数
-- - update(dt): 更新当前场景
-- - draw(): 绘制当前场景

local System = require("Engine.Core.System")

---
---@class SceneManager : System
---@field _registry table<string, Scene>
---@field current Scene|nil
local SceneManager = System:extend()

---
---@param app App
function SceneManager:init(app)
    self.app = app
    self._registry = {}
    self.current = nil
end

---
---@param name string
---@param scene Scene
function SceneManager:register(name, scene)
    self._registry[name] = scene
end

---
---@param name string
---@param params table|nil
function SceneManager:switch(name, params)
    local scene = self._registry[name]
    if not scene then
        error("Scene not found: " .. tostring(name))
    end
    -- 暂停旧场景的事件目标，避免残留监听干扰
    if self.current and self.app and self.app.pauseTarget then
        self.app:pauseTarget(self.current)
    end
    if self.current and self.current.leave then
        self.current:leave()
    end
    self.current = scene
    if self.current.enter then
        self.current:enter(params)
    end
    -- 恢复新场景的事件目标（若其监听使用 target=self）
    if self.current and self.app and self.app.resumeTarget then
        self.app:resumeTarget(self.current)
    end
end

---
---@param dt number
function SceneManager:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

---@return nil
function SceneManager:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

return SceneManager
