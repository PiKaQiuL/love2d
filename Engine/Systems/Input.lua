-- Engine/Input.lua
-- 输入系统：统一跟踪键盘与鼠标状态，并提供查询 API
-- 模块：输入系统
-- 功能：统一采集键鼠事件状态并提供查询接口
-- 依赖：Engine.System
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：将一次性状态（pressed/released/textBuffer）在 update 中清空，避免跨帧残留；不要在事件回调中做重计算或写磁盘。
--
-- 事件方法：
-- - keypressed/keyreleased/textinput
-- - mousepressed/mousereleased/mousemoved/wheelmoved
-- 查询方法：
-- - isDown/pressed/released
-- - mouseDown/mousePressed/mouseReleased
-- - mousePosition/mouseDelta/mouseWheel
-- - shiftDown/ctrlDown/altDown

local System = require("Engine.Core.System")

---
---@class Input : System
---@field keysDown table
---@field keysPressed table
---@field keysReleased table
---@field lastKey string|nil
---@field textBuffer string
---@field mouse table
local Input = System:extend()

---
function Input:init()
    -- 键盘状态
    self.keysDown = {}
    self.keysPressed = {}
    self.keysReleased = {}
    self.lastKey = nil

    -- 文本输入（本帧）
    self.textBuffer = ""

    -- 鼠标状态
    self.mouse = {
        x = 0, y = 0,
        dx = 0, dy = 0,
        buttonsDown = {},
        buttonsPressed = {},
        buttonsReleased = {},
        wheelX = 0, wheelY = 0
    }
end

-- 键盘事件
---
---@param key string
---@param scancode string|nil
---@param isrepeat boolean|nil
function Input:keypressed(key, scancode, isrepeat)
    if isrepeat then return end
    self.keysDown[key] = true
    self.keysPressed[key] = true
    self.lastKey = key
    if self.app and self.app.emit then
        self.app:emit("input:keypressed", key, scancode)
    end
end

---
---@param key string
---@param scancode string|nil
function Input:keyreleased(key, scancode)
    self.keysDown[key] = nil
    self.keysReleased[key] = true
    if self.app and self.app.emit then
        self.app:emit("input:keyreleased", key, scancode)
    end
end

function Input:textinput(text)
    self.textBuffer = self.textBuffer .. (text or "")
    if self.app and self.app.emit then
        self.app:emit("input:text", text)
    end
end

-- 鼠标事件
function Input:mousepressed(x, y, button, presses)
    self.mouse.x, self.mouse.y = x, y
    self.mouse.buttonsDown[button] = true
    self.mouse.buttonsPressed[button] = true
    if self.app and self.app.emit then
        self.app:emit("input:mousepressed", x, y, button, presses)
    end
end

function Input:mousereleased(x, y, button, presses)
    self.mouse.x, self.mouse.y = x, y
    self.mouse.buttonsDown[button] = nil
    self.mouse.buttonsReleased[button] = true
    if self.app and self.app.emit then
        self.app:emit("input:mousereleased", x, y, button, presses)
    end
end

function Input:mousemoved(x, y, dx, dy, istouch)
    self.mouse.x, self.mouse.y = x, y
    self.mouse.dx, self.mouse.dy = dx, dy
    if self.app and self.app.emit then
        self.app:emit("input:mousemoved", x, y, dx, dy, istouch)
    end
end

function Input:wheelmoved(dx, dy)
    self.mouse.wheelX = self.mouse.wheelX + (dx or 0)
    self.mouse.wheelY = self.mouse.wheelY + (dy or 0)
    if self.app and self.app.emit then
        self.app:emit("input:wheelmoved", dx, dy)
    end
end

-- 每帧清理一次性状态
function Input:update(dt)
    self.keysPressed = {}
    self.keysReleased = {}
    self.textBuffer = ""
    self.mouse.buttonsPressed = {}
    self.mouse.buttonsReleased = {}
    self.mouse.dx, self.mouse.dy = 0, 0
    self.mouse.wheelX, self.mouse.wheelY = 0, 0
end

-- 查询 API
function Input:isDown(key) return not not self.keysDown[key] end
function Input:pressed(key) return not not self.keysPressed[key] end
function Input:released(key) return not not self.keysReleased[key] end

function Input:mouseDown(button) return not not self.mouse.buttonsDown[button] end
function Input:mousePressed(button) return not not self.mouse.buttonsPressed[button] end
function Input:mouseReleased(button) return not not self.mouse.buttonsReleased[button] end
function Input:mousePosition() return self.mouse.x, self.mouse.y end
function Input:mouseDelta() return self.mouse.dx, self.mouse.dy end
function Input:mouseWheel() return self.mouse.wheelX, self.mouse.wheelY end

function Input:shiftDown()
    return love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
end
function Input:ctrlDown()
    return love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
end
function Input:altDown()
    return love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")
end

return Input
