-- Engine/UI/ProgressBar.lua
-- 进度条控件：支持 0..1 进度、主题颜色与描边

local Widget = require("Engine.UI.Widget")
local Defaults = require("Engine.UI.Defaults")

---@class ProgressBar : Widget
---@field value number
---@field min number
---@field max number
---@field colors { bg: number[], fill: number[], border: number[] }
---@field borderWidth number
---@overload fun(...):ProgressBar
local ProgressBar = Widget:extend()

function ProgressBar:init()
    Widget.init(self)
    self.w = 160
    self.h = 12
    self.min = 0
    self.max = 1
    self.value = 0
    self.colors = Defaults.progressColors
    self.borderWidth = 1
end

---@generic T : ProgressBar
---@param self T
---@param min number|nil
---@param max number|nil
---@return T
function ProgressBar:setRange(min, max)
    if min ~= nil then self.min = min end
    if max ~= nil then self.max = max end
    if self.max < self.min then self.max = self.min end
    self:setValue(self.value)
    return self
end

---@generic T : ProgressBar
---@param self T    
---@param v number
---@return T
function ProgressBar:setValue(v)
    ---@cast self ProgressBar
    v = tonumber(v) or self.value
    if v < self.min then v = self.min end
    if v > self.max then v = self.max end
    self.value = v
    return self
end

---@return number
function ProgressBar:getValue()
    return self.value
end

---@generic T : ProgressBar
---@param self T
---@param colors table
---@return T
function ProgressBar:setColors(colors)
    ---@cast self ProgressBar
    if colors then self.colors = colors end
    return self
end

--- 设置进度条尺寸
---@generic T : ProgressBar
---@param self T
---@param w number|nil
---@param h number|nil
---@return T
function ProgressBar:setSize(w, h)
    self.w = w or self.w
    self.h = h or self.h
    return self
end

--- 设置边框宽度
---@generic T : ProgressBar
---@param self T
---@param width number
---@return T
function ProgressBar:setBorderWidth(width)
    self.borderWidth = width or 1
    return self
end

function ProgressBar:render(x, y)
    local w = self.w * (self.sx or 1)
    local h = self.h * (self.sy or 1)
    local ratio = (self.max == self.min) and 0 or ((self.value - self.min) / (self.max - self.min))
    if ratio < 0 then ratio = 0 elseif ratio > 1 then ratio = 1 end

    -- 外框
    love.graphics.setLineWidth(self.borderWidth)
    if self.colors.bg then
        love.graphics.setColor(self.colors.bg)
        love.graphics.rectangle("fill", x, y, w, h)
    end
    if self.colors.border then
        love.graphics.setColor(self.colors.border)
        love.graphics.rectangle("line", x, y, w, h)
    end

    -- 填充
    if self.colors.fill then
        love.graphics.setColor(self.colors.fill)
        love.graphics.rectangle("fill", x + 1, y + 1, math.max(0, (w - 2) * ratio), h - 2)
    end

    love.graphics.setColor(1,1,1,1)
end

return ProgressBar
