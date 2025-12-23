-- Engine/UI/Panel.lua
-- 面板控件：支持 Color 对象和向后兼容的颜色格式
-- 模块：UI 面板
-- 功能：可填充、带边框的矩形容器，支持剪裁
-- 依赖：Engine.UI.Widget, Engine.UI.Defaults, Engine.Utils.ColorHelper
-- 作者：Team
-- 修改时间：2025-12-23

local Widget = require("Engine.UI.Widget")
local Defaults = require("Engine.UI.Defaults")
local ColorHelper = require("Engine.Utils.ColorHelper")

---@class Panel : Widget
---@overload fun(...):Panel
---@field w number
---@field h number
---@field fill Color
---@field border Color
---@field borderWidth number
---@field padding number
local Panel = Widget:extend()

function Panel:init()
    Widget.init(self)
    self.w = 100
    self.h = 60
    self.fill = Defaults.panel.fill
    self.border = Defaults.panel.border
    self.borderWidth = Defaults.panel.borderWidth or 1
    self.padding = 4
end

--- 在渲染前设置剪裁区域，避免内部子元素溢出
---@param x number
---@param y number
function Panel:preRender(x, y)
    love.graphics.setScissor(x, y, self.w, self.h)
end

--- 渲染后清除剪裁
function Panel:postRender()
    love.graphics.setScissor()
end

---
---@generic T : Panel
---@param self T
---@param w number
---@param h number
---@return T
function Panel:setSize(w, h)
    self.w, self.h = w, h
    return self
end

--- 设置填充色（支持多种格式）
---@generic T : Panel
---@param self T
---@param fill number|table|Color @颜色对象、颜色数组或红色分量
---@param g number|nil @绿色分量
---@param b number|nil @蓝色分量
---@param a number|nil @透明度
---@return T
function Panel:setFill(fill, g, b, a)
    if fill then
        self.fill = ColorHelper.toColor(fill, g, b, a)
    end
    return self
end

--- 设置边框颜色（支持多种格式）
---@generic T : Panel
---@param self T
---@param border number|table|Color @颜色对象、颜色数组或红色分量
---@param g number|nil @绿色分量
---@param b number|nil @蓝色分量
---@param a number|nil @透明度
---@return T
function Panel:setBorder(border, g, b, a)
    if border then
        self.border = ColorHelper.toColor(border, g, b, a)
    end
    return self
end

--- 设置边框宽度
---@generic T : Panel
---@param self T
---@param width number
---@return T
function Panel:setBorderWidth(width)
    self.borderWidth = width or 1
    return self
end

--- 设置内边距
---@generic T : Panel
---@param self T
---@param padding number
---@return T
function Panel:setPadding(padding)
    self.padding = padding or 4
    return self
end

---@param x number
---@param y number
function Panel:render(x, y)
    ColorHelper.apply(self.fill)
    love.graphics.rectangle("fill", x, y, self.w, self.h)
    ColorHelper.apply(self.border)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", x, y, self.w, self.h)
    love.graphics.setColor(1,1,1,1)
end

---@param mx number
---@param my number
---@return boolean
function Panel:hitTest(mx, my)
    local x, y, w, h = self:getWorldAABB()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

return Panel
