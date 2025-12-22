-- Engine/Scene.lua
-- 模块：场景基类
-- 功能：提供场景生命周期（enter/leave/update/draw）与 App 引用
-- 依赖：Engine.Object
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 可重写方法：
-- - enter(params): 场景进入时调用，params 为可选参数
-- - leave(): 场景退出时调用
-- - update(dt): 每帧更新逻辑
-- - draw(): 每帧绘制逻辑
--
-- 性能提示：尽量避免在 draw 中做复杂计算；把重计算挪到 update。
--
-- 可重写方法：
-- - enter(params): 场景进入时调用，params 为可选参数
-- - leave(): 场景退出时调用
-- - update(dt): 每帧更新逻辑
-- - draw(): 每帧绘制逻辑

local Object = require("Engine.Core.Object")

---
---@class Scene : Object
---@field app App
local Scene = Object:extend()

---
---@param app App
function Scene:init(app)
    self.app = app -- 引用 App，可访问事件/计时/存储
end

---
---@param params table|nil
function Scene:enter(params)
    -- 子类可重写：场景进入时参数处理
end

---@return nil
function Scene:leave()
    -- 子类可重写：场景退出清理
end

---
---@param dt number
function Scene:update(dt)
    -- 子类可重写
end

---@return nil
function Scene:draw()
    -- 子类可重写
end

---@param key string
---@param scancode string|nil
---@param isrepeat boolean|nil
function Scene:keypressed(key, scancode, isrepeat)
    -- 子类可重写
end

---@param key string
---@param scancode string|nil
function Scene:keyreleased(key, scancode)
    -- 子类可重写
end

---@param text string
function Scene:textinput(text)
    -- 子类可重写
end

---@param x number
---@param y number
---@param button integer
---@param istouch boolean|nil
---@param presses integer|nil
function Scene:mousepressed(x, y, button, istouch, presses)
    -- 子类可重写
end

---@param x number
---@param y number
---@param button integer
---@param istouch boolean|nil
---@param presses integer|nil
function Scene:mousereleased(x, y, button, istouch, presses)
    -- 子类可重写
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean|nil
function Scene:mousemoved(x, y, dx, dy, istouch)
    -- 子类可重写
end

---@param dx number
---@param dy number
function Scene:wheelmoved(dx, dy)
    -- 子类可重写
end

---@param id number
---@param x number
---@param y number
---@param dx number|nil
---@param dy number|nil
---@param pressure number|nil
function Scene:touchpressed(id, x, y, dx, dy, pressure)
    -- 子类可重写
end

---@param id number
---@param x number
---@param y number
---@param dx number|nil
---@param dy number|nil
---@param pressure number|nil
function Scene:touchmoved(id, x, y, dx, dy, pressure)
    -- 子类可重写
end

---@param id number
---@param x number
---@param y number
---@param dx number|nil
---@param dy number|nil
---@param pressure number|nil
function Scene:touchreleased(id, x, y, dx, dy, pressure)
    -- 子类可重写
end

return Scene
