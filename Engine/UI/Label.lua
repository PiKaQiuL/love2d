-- Engine/UI/Label.lua
-- 文本标签控件：支持 Color 对象和向后兼容的颜色格式
-- 模块：UI 标签
-- 功能：显示文本，支持自定义字体和颜色
-- 依赖：Engine.UI.Widget, Engine.UI.Defaults, Engine.Utils.ColorHelper
-- 作者：Team
-- 修改时间：2025-12-23

local Widget = require("Engine.UI.Widget")
local Defaults = require("Engine.UI.Defaults")
local ColorHelper = require("Engine.Utils.ColorHelper")

---@class Label : Widget
---@field text string
---@field color Color
---@field font love.Font|nil
---@overload fun(...):self
local Label = Widget:extend()

function Label:init()
    Widget.init(self)
    self.text = ""
    self.color = Defaults.textColor
    self.font = nil
end

---@generic T : Label
---@param self T
---@param t string|nil
---@return T
function Label:setText(t)
    self.text = tostring(t or "")
    return self
end

--- 设置颜色（支持多种格式）
---@generic T : Label
---@param self T
---@param r number|table|Color|nil @红色分量、颜色对象或颜色数组
---@param g number|nil @绿色分量
---@param b number|nil @蓝色分量
---@param a number|nil @透明度
---@return T
function Label:setColor(r, g, b, a)
    self.color = ColorHelper.toColor(r, g, b, a)
    return self
end

---@generic T : Label
---@param self T
---@param font love.Font
---@return T
function Label:setFont(font)
    self.font = font
    return self
end

---
---@param x number
---@param y number
function Label:render(x, y)
    local prevFont = love.graphics.getFont()
    if self.font then love.graphics.setFont(self.font) end
    ColorHelper.apply(self.color)
    love.graphics.print(self.text, x, y)
    love.graphics.setColor(1, 1, 1, 1)
    if self.font then love.graphics.setFont(prevFont) end
end

return Label
