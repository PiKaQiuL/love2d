-- Engine/UI/Panel.lua
local Widget = require("Engine.UI.Widget")
local Defaults = require("Engine.UI.Defaults")

---
---@class Panel : Widget
---@field w number
---@field h number
---@field fill number[]
---@field border number[]
---@field borderWidth number
---@field padding number
local Panel = Widget:extend()

---
---@param x number
---@param y number
---@param w number
---@param h number
---@param opts table|nil
function Panel:init(x, y, w, h, opts)
    opts = opts or {}
    local pw = w or 100
    local ph = h or 60
    Widget.init(self, x or 0, y or 0, pw, ph, opts)
    self.w = pw
    self.h = ph
    self.fill = opts.fill or Defaults.panel.fill
    self.border = opts.border or Defaults.panel.border
    self.borderWidth = opts.borderWidth or Defaults.panel.borderWidth or 1
    self.padding = opts.padding or 4
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
---@param w number
---@param h number
function Panel:setSize(w, h)
    self.w, self.h = w, h
    return self
end

---@param x number
---@param y number
function Panel:render(x, y)
    love.graphics.setColor(self.fill)
    love.graphics.rectangle("fill", x, y, self.w, self.h)
    love.graphics.setColor(self.border)
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
