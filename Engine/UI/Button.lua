-- Engine/UI/Button.lua
--- 按钮控件：支持鼠标与键盘激活、焦点与状态描边
-- 模块：按钮控件
-- 功能：点击与键盘激活，支持 hover/pressed/disabled/focus 状态
-- 依赖：Engine.Node, Engine.UI.Label, Engine.Enums, Engine.UI.Defaults, Engine.Utils.ColorHelper
-- 作者：Team
-- 修改时间：2025-12-23
--
-- 性能提示：按钮绘制为简单矩形，适合文本 UI；若大量按钮同时存在，尽量减少每帧状态重计算和多次 setLineWidth 调用。
local Widget = require("Engine.UI.Widget")
local Label = require("Engine.UI.Label")
local Enums = require("Engine.Core.Enums")
local Defaults = require("Engine.UI.Defaults")
local ColorHelper = require("Engine.Utils.ColorHelper")


---@class ButtonColors
---@field normal Color
---@field hover Color
---@field pressed Color
---@field disabled Color
---@field border Color
---@field text Color
---@field focus Color

--- 创建按钮时可选参数
---@class ButtonOptions
---@field disabled boolean|nil         是否禁用
---@field focused boolean|nil          初始是否聚焦
---@field onClick fun(self: Button)|nil 点击回调（接收自身）
---@field colors ButtonColors|nil      颜色集，默认取 Defaults.buttonColors
---@field borderWidth number|nil       边框宽度，默认 1

---@class Button : Widget
---@field text string                 文本
---@field w number                    宽度
---@field h number                    高度
---@field state ButtonState           按钮状态（参考 Enums.ButtonState）
---@field disabled boolean            是否禁用
---@field focused boolean             是否聚焦
---@field onClick fun(self: Button)|nil 点击回调
---@field colors ButtonColors         颜色集
---@field borderWidth number          边框宽度
---@field label Label                 文本标签
---@overload fun(...):self
local Button = Widget:extend()



function Button:init()
    Widget.init(self)
    self.w = 120
    self.h = 30
    self.text = "Button"
    self.state = Enums.ButtonState.normal
    self.disabled = false
    self.focused = false
    self.onClick = nil
    self.colors = Defaults.buttonColors
    self.borderWidth = 1
    self.label = Label()
        :setText(self.text)
        :setColor(self.colors.text)
        :setPosition(8, (self.h - 14) / 2)
        :setVisible(false)
    
    self:add(self.label)
end

---
---@generic T : Button
---@param self T
---@param d boolean|nil
---@return T
function Button:setDisabled(d)
    self.disabled = not not d
    self.state = self.disabled and Enums.ButtonState.disabled or Enums.ButtonState.normal
    return self
end

--- 设置按预文本
---@generic T : Button
---@param self T
---@param text string
---@return T
function Button:setText(text)
    ---@cast self Button
    self.text = tostring(text or "")
    if self.label then
        self.label:setText(self.text)
        self.label:setVisible(true)
    end
    return self
end

--- 设置按预文本颜色（支持多种格式）
---@generic T : Button
---@param self T
---@param color number|table|Color @颜色对象、颜色数组或红色分量
---@param g number|nil @绿色分量
---@param b number|nil @蓝色分量
---@param a number|nil @透明度
---@return T
function Button:setTextColor(color, g, b, a)
    ---@cast self Button
    if self.label then
        self.label:setColor(color, g, b, a)
    end
    return self
end

--- 设置按预尺寸
---@generic T : Button
---@param self T
---@param w number|nil
---@param h number|nil
---@return T
function Button:setSize(w, h)
    ---@cast self Button
    self.w = w or self.w
    self.h = h or self.h
    if self.label then
        self.label:setPosition(8, (self.h - 14) / 2)
    end
    return self
end

--- 设置按预颜色集
---@generic T : Button
---@param self T
---@param colors ButtonColors
---@return T
function Button:setColors(colors)
    if colors then
        self.colors = colors
    end
    return self
end

--- 设置边框宽度
---@generic T : Button
---@param self T
---@param width number
---@return T
function Button:setBorderWidth(width)
    self.borderWidth = width or 1
    return self
end

--- 设置点击回调
---@generic T : Button
---@param self T
---@param callback fun(self: Button)|nil
---@return T
function Button:setOnClick(callback)
    self.onClick = callback
    return self
end

---comment
---@param x number
---@param y number
function Button:render(x, y)
    local c = self.colors[self.state] or self.colors[Enums.ButtonState.normal]
    ColorHelper.apply(c)
    love.graphics.rectangle("fill", x, y, self.w, self.h, 4, 4)
    love.graphics.setLineWidth(self.borderWidth)
    ColorHelper.apply(self.colors.border)
    love.graphics.rectangle("line", x, y, self.w, self.h, 4, 4)
    if self.focused and not self.disabled then
        ColorHelper.apply(self.colors.focus)
        love.graphics.setLineWidth(self.borderWidth + 1)
        love.graphics.rectangle("line", x + 2, y + 2, self.w - 4, self.h - 4, 4, 4)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

---@param mx number
---@param my number
---@return boolean
function Button:hitTest(mx, my)
    local x, y, w, h = self:getWorldAABB()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

---@param x number
---@param y number
function Button:mousemoved(x, y)
    if self.disabled then return end
    if self:hitTest(x, y) then
        if self.state ~= Enums.ButtonState.pressed then self.state = Enums.ButtonState.hover end
    else
        self.state = Enums.ButtonState.normal
    end
end

---comment
---@param x number
---@param y number
---@param button integer
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

---comment
---@param x number
---@param y number
---@param button integer
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

---comment
---@param f boolean
---@return Button
function Button:setFocus(f)
    self.focused = not not f
    return self
end

---comment
---@param key love.KeyConstant
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
