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

    -- 触摸状态（移动端）：支持多指追踪，并将首指映射为鼠标左键
    self.touches = {
        down = {},       -- id -> { x, y, pressure }
        pressed = {},    -- id -> true (本帧)
        released = {}    -- id -> true (本帧)
    }
    self.primaryTouchId = nil

    -- 时间轴与手势配置
    self.time = 0
    self.gesture = {
        longPressTime = 0.5,     -- 秒
        doubleTapTime = 0.3,     -- 两次点击最大间隔
        moveTolerance = 12,      -- 视为点击/长按的最大移动距离
        doubleTapDist = 22,      -- 双击两次位置最大距离
        lastTapTime = nil,
        lastTapX = nil,
        lastTapY = nil
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

-- 触摸事件（移动端）
function Input:touchpressed(id, x, y, dx, dy, pressure)
    pressure = pressure or 1
    self.touches.down[id] = {
        x = x, y = y, pressure = pressure,
        startX = x, startY = y,
        startTime = self.time,
        maxDist = 0,
        longFired = false
    }
    self.touches.pressed[id] = true
    if not self.primaryTouchId then
        self.primaryTouchId = id
        -- 映射为鼠标左键，提升 UI 兼容性
        self:mousepressed(x, y, 1, 1)
    end
    if self.app and self.app.emit then
        self.app:emit("input:touchpressed", id, x, y, pressure)
    end
end

function Input:touchmoved(id, x, y, dx, dy, pressure)
    local t = self.touches.down[id]
    if t then
        t.x, t.y, t.pressure = x, y, pressure or t.pressure
        local dxs = (t.x - t.startX)
        local dys = (t.y - t.startY)
        local dist = math.sqrt(dxs*dxs + dys*dys)
        if dist > t.maxDist then t.maxDist = dist end
    end
    if self.primaryTouchId == id then
        self:mousemoved(x, y, dx or 0, dy or 0, true)
    end
    if self.app and self.app.emit then
        self.app:emit("input:touchmoved", id, x, y, dx or 0, dy or 0, pressure)
    end
end

function Input:touchreleased(id, x, y, dx, dy, pressure)
    self.touches.down[id] = nil
    self.touches.released[id] = true
    -- 点击/双击检测
    local g = self.gesture
    local now = self.time
    local isTap = true
    if dx or dy then end -- 占位，兼容签名
    local last = nil
    -- 由于上面已移除 down，这里无法取 meta；改用参数位置近似判断
    -- 允许根据移动阈值判断点击（若可用，dx/dy 在 touch 系列通常不可靠，忽略）
    -- 双击：时间与位置都在阈值内
    if g.lastTapTime and (now - g.lastTapTime) <= g.doubleTapTime then
        if g.lastTapX and g.lastTapY then
            local dx2 = (x - g.lastTapX); local dy2 = (y - g.lastTapY)
            local dist2 = math.sqrt(dx2*dx2 + dy2*dy2)
            if dist2 <= g.doubleTapDist then
                if self.app and self.app.emit then
                    self.app:emit("input:gesture:doubletap", x, y, id)
                end
                -- 重置
                g.lastTapTime, g.lastTapX, g.lastTapY = nil, nil, nil
                isTap = false
            end
        end
    end
    if isTap then
        -- 记录这次点击作为可能的双击第一次
        g.lastTapTime, g.lastTapX, g.lastTapY = now, x, y
        if self.app and self.app.emit then
            self.app:emit("input:gesture:tap", x, y, id)
        end
    end
    if self.primaryTouchId == id then
        self:mousereleased(x, y, 1, 1)
        self.primaryTouchId = nil
    end
    if self.app and self.app.emit then
        self.app:emit("input:touchreleased", id, x, y, pressure)
    end
end

-- 每帧清理一次性状态
function Input:update(dt)
    self.time = self.time + (dt or 0)
    self.keysPressed = {}
    self.keysReleased = {}
    self.textBuffer = ""
    self.mouse.buttonsPressed = {}
    self.mouse.buttonsReleased = {}
    self.mouse.dx, self.mouse.dy = 0, 0
    self.mouse.wheelX, self.mouse.wheelY = 0, 0
    self.touches.pressed = {}
    self.touches.released = {}

    -- 长按检测：保持按下且移动未超过阈值、时间达到阈值则触发一次
    local g = self.gesture
    for id, t in pairs(self.touches.down) do
        if not t.longFired then
            local held = (self.time - (t.startTime or self.time))
            if held >= g.longPressTime and (t.maxDist or 0) <= g.moveTolerance then
                t.longFired = true
                if self.app and self.app.emit then
                    self.app:emit("input:gesture:longpress", t.x, t.y, id, held)
                end
            end
        end
    end
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

-- 触摸查询 API
function Input:touchDown(id) return not not self.touches.down[id] end
function Input:touchPressed(id) return not not self.touches.pressed[id] end
function Input:touchReleased(id) return not not self.touches.released[id] end
function Input:touchCount()
    local n = 0; for _ in pairs(self.touches.down) do n = n + 1 end; return n
end
function Input:primaryTouchPosition()
    local id = self.primaryTouchId
    if not id then return nil end
    local t = self.touches.down[id]
    if not t then return nil end
    return t.x, t.y, id
end

return Input
