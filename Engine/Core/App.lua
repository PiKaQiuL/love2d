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
local App = Object:extend()

---
function App:init()
    self.events = EventBus()
    self.timer = Timer()
    self.storage = Storage()
    self.scenes = SceneManager(self)
    self.systems = {}
    self.style = Style()
end

---
---@param sys System
function App:addSystem(sys)
    self.systems[#self.systems + 1] = sys
    sys.app = self
    if sys.init then sys:init() end
end

---
---@param dt number
function App:update(dt)
    self.timer:update(dt)
    for i = 1, #self.systems do
        local s = self.systems[i]
        if s.update then s:update(dt) end
    end
    self.scenes:update(dt)
end


function App:draw()
    for i = 1, #self.systems do
        local s = self.systems[i]
        if s.draw then s:draw() end
    end
    self.scenes:draw()
end

---@param key string
---@param scancode string|nil
---@param isrepeat boolean|nil
function App:keypressed(key, scancode, isrepeat)
    for i = 1, #self.systems do
        local s = self.systems[i]
        if s.keypressed then s:keypressed(key, scancode, isrepeat) end
    end
    if self.scenes.current and self.scenes.current.keypressed then
        self.scenes.current:keypressed(key, scancode, isrepeat)
    end
end

---@param text string
function App:textinput(text)
    for i = 1, #self.systems do
        local s = self.systems[i]
        if s.textinput then s:textinput(text) end
    end
    if self.scenes.current and self.scenes.current.textinput then
        self.scenes.current:textinput(text)
    end
end

---@param key string
---@param scancode string|nil
function App:keyreleased(key, scancode)
    for i = 1, #self.systems do
        local s = self.systems[i]
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
    for i = 1, #self.systems do
        local s = self.systems[i]
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
    for i = 1, #self.systems do
        local s = self.systems[i]
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
    for i = 1, #self.systems do
        local s = self.systems[i]
        if s.mousemoved then s:mousemoved(x, y, dx, dy, istouch) end
    end
    if self.scenes.current and self.scenes.current.mousemoved then
        self.scenes.current:mousemoved(x, y, dx, dy, istouch)
    end
end

---@param dx number
---@param dy number
function App:wheelmoved(dx, dy)
    for i = 1, #self.systems do
        local s = self.systems[i]
        if s.wheelmoved then s:wheelmoved(dx, dy) end
    end
    if self.scenes.current and self.scenes.current.wheelmoved then
        self.scenes.current:wheelmoved(dx, dy)
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

