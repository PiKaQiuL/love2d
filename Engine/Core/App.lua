-- Engine/App.lua
-- 模块：应用总控
-- 功能：聚合事件总线、计时器、场景管理与系统集合；转发输入
-- 依赖：Engine.Object, Engine.EventBus, Engine.Timer, Engine.SceneManager, Engine.Storage, Engine.UI.Style
-- 作者：Team
-- 修改时间：2025-12-21
--
-- - keypressed/keyreleased/textinput/...: 输入事件转发到系统与当前场景
-- - on/emit/once: 事件总线代理
-- - off: 事件总线取消订阅
-- - pauseTarget/resumeTarget/offTarget: 目标级事件控制便捷代理
-- - switchScene(name, params): 切换场景
-- - save/load: 简易存档
--
-- 性能提示：系统列表与场景绘制在每帧调用；避免在此处分配大对象或做阻塞 IO。
--


local Object = require("Engine.Core.Object")
local EventBus = require("Engine.Systems.EventBus")
local Timer = require("Engine.Systems.Timer")
local SceneManager = require("Engine.Core.SceneManager")
local Storage = require("Engine.Systems.Storage")
local Style = require("Engine.UI.Style")

---
---@class App : Object
---@field events EventBus
---@field timer Timer
---@field storage Storage
---@field scenes SceneManager
---@field systems System[]
---@field style Style
---@field input Input|nil
---@field animation Animation|nil
---@field logger Logger|nil
local App = Object:extend()

---
function App:init()
    self.events = EventBus()
    self.timer = Timer()
    self.storage = Storage()
    self.scenes = SceneManager(self)
    self.systems = {}
    self.style = Style()
    self._evt = {}
    self._sysByKey = {}
end

---
---@param sys System
---@param key string|nil
function App:addSystem(sys, key)
    self.systems[#self.systems + 1] = sys
    sys.app = self
    if key then self._sysByKey[key] = sys end
    local names = {
        "update","draw",
        "keypressed","keyreleased","textinput",
        "mousepressed","mousereleased","mousemoved","wheelmoved",
        "touchpressed","touchmoved","touchreleased"
    }
    for i = 1, #names do
        local m = names[i]
        if sys[m] then
            local list = self._evt[m]
            if not list then list = {}; self._evt[m] = list end
            list[#list + 1] = sys
        end
    end
    if sys.init then sys:init() end
end

---
---@param keyOrClass any|string  @字符串键、类，或实例本身
---@return boolean               @是否成功移除
function App:removeSystem(keyOrClass)
    local target = nil
    if type(keyOrClass) == "string" then
        target = self._sysByKey[keyOrClass]
    elseif type(keyOrClass) == "table" then
        -- 实例优先：具有 app 或 is() 能力的认为是实例
        if keyOrClass.app or (keyOrClass.is and keyOrClass:is(Object)) then
            target = keyOrClass
        else
            -- 视为类：查找首个匹配实例
            for i = 1, #self.systems do
                local s = self.systems[i]
                if s.is and s:is(keyOrClass) then target = s; break end
            end
        end
    end
    if not target then return false end

    -- 从系统数组移除
    local idx = nil
    for i = 1, #self.systems do if self.systems[i] == target then idx = i; break end end
    if not idx then return false end
    table.remove(self.systems, idx)

    -- 从事件索引移除
    for m, list in pairs(self._evt) do
        for i = #list, 1, -1 do
            if list[i] == target then table.remove(list, i) end
        end
        if #list == 0 then self._evt[m] = nil end
    end

    -- 清理 key 映射
    for k, v in pairs(self._sysByKey) do if v == target then self._sysByKey[k] = nil end end

    -- 生命周期回调
    if target.reset then pcall(target.reset, target) end
    target.app = nil
    return true
end

---
---@param Class any         @系统类
---@param key string|nil    @可选键名
---@param ... any
---@return System
function App:ensureSystem(Class, key, ...)
    if type(key) == "string" then
        local s = self._sysByKey[key]
        if s and s.is and s:is(Class) then return s end
    end
    -- 按类查找
    for i = 1, #self.systems do
        local s = self.systems[i]
        if s.is and s:is(Class) then
            if type(key) == "string" then self._sysByKey[key] = s end
            return s
        end
    end
    -- 创建并注册
    local inst = Class(...)
    self:addSystem(inst, type(key) == "string" and key or nil)
    return inst
end

---
---@param keyOrClass any
---@return System|nil
function App:getSystem(keyOrClass)
    if type(keyOrClass) == "string" then
        return self._sysByKey[keyOrClass]
    end
    if type(keyOrClass) == "table" then
        for i = 1, #self.systems do
            local s = self.systems[i]
            if s.is and s:is(keyOrClass) then return s end
        end
    end
    return nil
end

---
---@param dt number
function App:update(dt)
    self.timer:update(dt)
    local list = self._evt.update or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.update then s:update(dt) end
    end
    self.scenes:update(dt)
end


function App:draw()
    local list = self._evt.draw or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.draw then s:draw() end
    end
    self.scenes:draw()
end

---@param key string
---@param scancode string|nil
---@param isrepeat boolean|nil
function App:keypressed(key, scancode, isrepeat)
    local list = self._evt.keypressed or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.keypressed then s:keypressed(key, scancode, isrepeat) end
    end
    if self.scenes.current and self.scenes.current.keypressed then
        self.scenes.current:keypressed(key, scancode, isrepeat)
    end
end

---@param text string
function App:textinput(text)
    local list = self._evt.textinput or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.textinput then s:textinput(text) end
    end
    if self.scenes.current and self.scenes.current.textinput then
        self.scenes.current:textinput(text)
    end
end

---@param key string
---@param scancode string|nil
function App:keyreleased(key, scancode)
    local list = self._evt.keyreleased or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.keyreleased then s:keyreleased(key, scancode) end
    end
    if self.scenes.current and self.scenes.current.keyreleased then
        self.scenes.current:keyreleased(key, scancode)
    end
end

---@param x number
---@param y number
---@param button integer
---@param presses integer|nil
function App:mousepressed(x, y, button, presses)
    local list = self._evt.mousepressed or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.mousepressed then s:mousepressed(x, y, button, presses) end
    end
    if self.scenes.current and self.scenes.current.mousepressed then
        self.scenes.current:mousepressed(x, y, button, presses)
    end
end

---@param x number
---@param y number
---@param button integer
---@param presses integer|nil
function App:mousereleased(x, y, button, presses)
    local list = self._evt.mousereleased or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.mousereleased then s:mousereleased(x, y, button, presses) end
    end
    if self.scenes.current and self.scenes.current.mousereleased then
        self.scenes.current:mousereleased(x, y, button, presses)
    end
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean|nil
function App:mousemoved(x, y, dx, dy, istouch)
    local list = self._evt.mousemoved or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.mousemoved then s:mousemoved(x, y, dx, dy, istouch) end
    end
    if self.scenes.current and self.scenes.current.mousemoved then
        self.scenes.current:mousemoved(x, y, dx, dy, istouch)
    end
end

---@param dx number
---@param dy number
function App:wheelmoved(dx, dy)
    local list = self._evt.wheelmoved or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.wheelmoved then s:wheelmoved(dx, dy) end
    end
    if self.scenes.current and self.scenes.current.wheelmoved then
        self.scenes.current:wheelmoved(dx, dy)
    end
end

-- 触摸事件（移动端）
function App:touchpressed(id, x, y, dx, dy, pressure)
    local list = self._evt.touchpressed or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.touchpressed then s:touchpressed(id, x, y, dx, dy, pressure) end
    end
    if self.scenes.current and self.scenes.current.touchpressed then
        self.scenes.current:touchpressed(id, x, y, dx, dy, pressure)
    end
end

function App:touchmoved(id, x, y, dx, dy, pressure)
    local list = self._evt.touchmoved or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.touchmoved then s:touchmoved(id, x, y, dx, dy, pressure) end
    end
    if self.scenes.current and self.scenes.current.touchmoved then
        self.scenes.current:touchmoved(id, x, y, dx, dy, pressure)
    end
end

function App:touchreleased(id, x, y, dx, dy, pressure)
    local list = self._evt.touchreleased or self.systems
    for i = 1, #list do
        local s = list[i]
        if s.touchreleased then s:touchreleased(id, x, y, dx, dy, pressure) end
    end
    if self.scenes.current and self.scenes.current.touchreleased then
        self.scenes.current:touchreleased(id, x, y, dx, dy, pressure)
    end
end


---@param event string
---@param handler fun(...):boolean|nil
---@param opts table|nil @{ priority: integer|nil, target: any|nil }
---@return any
function App:on(event, handler, opts)
    return self.events:on(event, handler, opts)
end

---@param event string
---@param ... any
---@return nil
function App:emit(event, ...)
    self.events:emit(event, ...)
end

---@param event string
---@param handler fun(...):boolean|nil
---@param opts table|nil @{ priority: integer|nil, target: any|nil }
---@return any
function App:once(event, handler, opts)
    return self.events:once(event, handler, opts)
end

---@param event string
---@param handler any
---@return boolean|nil
function App:off(event, handler)
    return self.events:off(event, handler)
end

---@param target any
---@return nil
function App:pauseTarget(target)
    return self.events:pauseTarget(target)
end

---@param target any
---@return nil
function App:resumeTarget(target)
    return self.events:resumeTarget(target)
end

---@param target any
---@return nil
function App:offTarget(target)
    return self.events:offTarget(target)
end

---@param name string
---@param params table|nil
---@return nil
function App:switchScene(name, params)
    self.scenes:switch(name, params)
end

---@param name string
---@param data table
---@return boolean
function App:save(name, data)
    return self.storage:save(name, data)
end

---@param name string
---@return table|nil
function App:load(name)
    return self.storage:load(name)
end

return App

