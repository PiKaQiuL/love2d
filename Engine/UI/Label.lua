-- Engine/UI/Label.lua
local Widget = require("Engine.UI.Widget")
local Defaults = require("Engine.UI.Defaults")

---
---@class Label : Widget
---@field text string
---@field color number[]
---@field font love.Font|nil
local Label = Widget:extend()

---
---@param text string|nil
---@param x number|nil
---@param y number|nil
---@param color table|nil
function Label:init(text, x, y, color)
    Widget.init(self, x or 0, y or 0, 0, 0)
    self.text = tostring(text or "")
    self.color = color or Defaults.textColor
    self.font = nil
end

---
---@param t string|nil
function Label:setText(t)
    self.text = tostring(t or "")
    return self
end

---
---@param r number|nil
---@param g number|nil
---@param b number|nil
---@param a number|nil
function Label:setColor(r, g, b, a)
    self.color = { r or 1, g or 1, b or 1, a or 1 }
    return self
end

---
---@param font love.Font
function Label:setFont(font)
    self.font = font
    return self
end

---
---@return nil
---@param x number
---@param y number
function Label:render(x, y)
    local prevFont = love.graphics.getFont()
    if self.font then love.graphics.setFont(self.font) end
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, x, y)
    love.graphics.setColor(1, 1, 1, 1)
    if self.font then love.graphics.setFont(prevFont) end
end

return Label
