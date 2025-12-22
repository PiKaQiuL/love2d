-- Engine/UI/Button.lua
--- 按钮控件：支持鼠标与键盘激活、焦点与状态描边
-- 模块：按钮控件
-- 功能：点击与键盘激活，支持 hover/pressed/disabled/focus 状态
-- 依赖：Engine.Node, Engine.UI.Label, Engine.Enums, Engine.UI.Defaults
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：按钮绘制为简单矩形，适合文本 UI；若大量按钮同时存在，尽量减少每帧状态重计算和多次 setLineWidth 调用。
local Widget = require("Engine.UI.Widget")
local Label = require("Engine.UI.Label")
local Enums = require("Engine.Core.Enums")
local Defaults = require("Engine.UI.Defaults")

---@class Button : Widget
---@field focused boolean
---@field onClick function|nil
---@field colors table
---@field borderWidth number
---@field label Label
local Button = Widget:extend()


-- @param y number
-- @param w number
-- @param h number
-- @param opts table|nil
function Button:init(text, x, y, w, h, opts)
    opts = opts or {}
    local bw = w or 120
    local bh = h or 30
    Widget.init(self, x or 0, y or 0, bw, bh, opts)
    self.w = bw
    self.h = bh
    self.text = tostring(text or "Button")
    self.state = Enums.ButtonState.normal
    self.disabled = opts.disabled or false
    self.focused = opts.focused or false
    self.onClick = opts.onClick
    self.colors = opts.colors or Defaults.buttonColors
    self.borderWidth = opts.borderWidth or 1
    self.label = Label(self.text, 0, 0, self.colors.text)
    self.label:setPosition(8, (self.h - 14) / 2)
    self:add(self.label)
end


---
---@param d boolean|nil
function Button:setDisabled(d)
    self.disabled = not not d
    self.state = self.disabled and Enums.ButtonState.disabled or Enums.ButtonState.normal
    return self
end

function Button:render(x, y)
    local c = self.colors[self.state] or self.colors[Enums.ButtonState.normal]
    love.graphics.setColor(c)
    love.graphics.rectangle("fill", x, y, self.w, self.h, 4, 4)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle("line", x, y, self.w, self.h, 4, 4)
    if self.focused and not self.disabled then
        love.graphics.setColor(self.colors.focus)
        love.graphics.setLineWidth(self.borderWidth + 1)
        love.graphics.rectangle("line", x + 2, y + 2, self.w - 4, self.h - 4, 4, 4)
    end
    love.graphics.setColor(1,1,1,1)
end

function Button:hitTest(mx, my)
    local x, y = self:getWorldPosition()
    local w = self.w * (self.sx or 1)
    local h = self.h * (self.sy or 1)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function Button:mousemoved(x, y)
    if self.disabled then return end
    if self:hitTest(x, y) then
        if self.state ~= Enums.ButtonState.pressed then self.state = Enums.ButtonState.hover end
    else
        self.state = Enums.ButtonState.normal
    end
end

function Button:mousepressed(x, y, button)
    if self.disabled then return end
    if button == Enums.MouseButton.left then
        self.focused = self:hitTest(x, y)
        if self.focused then
            self.state = Enums.ButtonState.pressed
        else
            self.state = Enums.ButtonState.normal
        end
    end
end

function Button:mousereleased(x, y, button)
    if self.disabled then return end
    if button == Enums.MouseButton.left then
        local wasPressed = self.state == Enums.ButtonState.pressed
        self.state = self:hitTest(x, y) and Enums.ButtonState.hover or Enums.ButtonState.normal
        if wasPressed and self:hitTest(x, y) and self.onClick then
            self.onClick(self)
        end
    end
end

function Button:setFocus(f)
    self.focused = not not f
    return self
end

function Button:keypressed(key)
    if self.disabled or not self.focused then return end
    if key == "return" or key == "space" then
        local prevState = self.state
        self.state = Enums.ButtonState.pressed
        if self.onClick then self.onClick(self) end
        -- 键盘触发后回到 hover/normal
        self.state = prevState == Enums.ButtonState.hover and Enums.ButtonState.hover or Enums.ButtonState.normal
    end
end

return Button
