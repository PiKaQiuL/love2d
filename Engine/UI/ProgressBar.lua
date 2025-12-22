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
local ProgressBar = Widget:extend()

---@param x number|nil
---@param y number|nil
---@param w number|nil
---@param h number|nil
---@param opts table|nil @{ value:number|nil, min:number|nil, max:number|nil, colors:table|nil, borderWidth:number|nil }
function ProgressBar:init(x, y, w, h, opts)
    opts = opts or {}
    Widget.init(self, x or 0, y or 0, w or 160, h or 12, opts)
    self.min = opts.min or 0
    self.max = opts.max or 1
    self.value = math.max(self.min, math.min(opts.value or 0, self.max))
    self.colors = opts.colors or Defaults.progressColors
    self.borderWidth = opts.borderWidth or 1
end

function ProgressBar:setRange(min, max)
    if min ~= nil then self.min = min end
    if max ~= nil then self.max = max end
    if self.max < self.min then self.max = self.min end
    self:setValue(self.value)
    return self
end

function ProgressBar:setValue(v)
    v = tonumber(v) or self.value
    if v < self.min then v = self.min end
    if v > self.max then v = self.max end
    self.value = v
    return self
end

function ProgressBar:getValue()
    return self.value
end

function ProgressBar:setColors(colors)
    if colors then self.colors = colors end
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
