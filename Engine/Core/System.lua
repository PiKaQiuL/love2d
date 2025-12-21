-- Engine/System.lua
-- Love2D OOP 基础系统框架
-- 模块：系统基类
-- 功能：为具体系统提供统一生命周期；与 App 集成
-- 依赖：Engine.Object
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 可重写方法：
-- - init(): 系统初始化
-- - update(dt): 每帧更新
-- - draw(): 每帧绘制
-- - reset(): 重置系统状态

local Object = require("Engine.Core.Object")

---
---@class System : Object
---@field app App
local System = Object:extend()

---
function System:init()
    -- 可在子类中重写
end

---
---@param dt number
function System:update(dt)
    -- 可在子类中重写
end

function System:draw()
    -- 可在子类中重写
end

function System:reset()
    -- 可在子类中重写
end

---@param key string
---@param scancode string|nil
---@param isrepeat boolean|nil
function System:keypressed(key, scancode, isrepeat)
    -- 可在子类中重写
end

---@param text string
function System:textinput(text)
    -- 可在子类中重写
end

---@param key string
---@param scancode string|nil
function System:keyreleased(key, scancode)
    -- 可在子类中重写
end

---@param x number
---@param y number
---@param button integer
---@param presses integer|nil
function System:mousepressed(x, y, button, presses)
    -- 可在子类中重写
end

---@param x number
---@param y number
---@param button integer
---@param presses integer|nil
function System:mousereleased(x, y, button, presses)
    -- 可在子类中重写
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param istouch boolean|nil
function System:mousemoved(x, y, dx, dy, istouch)
    -- 可在子类中重写
end

---@param dx number
---@param dy number
function System:wheelmoved(dx, dy)
    -- 可在子类中重写
end

return System
