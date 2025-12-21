-- Game/UI/TextPanel.lua
-- 简单文本面板，支持多行绘制

local Object = require("Engine.Core.Object")
local Pool = require("Engine.Systems.Pool")

---
---@class TextPanel : Object
---@field x number
---@field y number
---@field w number
---@field lines table
---@field maxLines integer|nil
---@field usePool boolean
---@field _pool Pool|nil
local TextPanel = Object:extend()

---@param x number|nil
---@param y number|nil
---@param w number|nil
---@param opts table|nil @{ usePool:boolean|nil, maxLines:number|nil }
function TextPanel:init(x, y, w, opts)
    opts = opts or {}
    self.x = x or 10
    self.y = y or 200
    self.w = w or 480
    self.lines = {}
    self.maxLines = opts.maxLines
    self.usePool = opts.usePool == true
    if self.usePool then
        self._pool = Pool({
            factory = function() return { text = "" } end,
            reset = function(o) o.text = "" end,
            maxSize = 256
        })
    end
end

---@param text any
function TextPanel:add(text)
    local s = tostring(text)
    if self.usePool then
        local item = self._pool:acquire()
        item.text = s
        self.lines[#self.lines + 1] = item
    else
        self.lines[#self.lines + 1] = s
    end
    if self.maxLines and #self.lines > self.maxLines then
        local first = table.remove(self.lines, 1)
        if self.usePool and type(first) == "table" then
            self._pool:release(first)
        end
    end
end

function TextPanel:clear()
    if self.usePool then
        for i = 1, #self.lines do
            local item = self.lines[i]
            if type(item) == "table" then
                self._pool:release(item)
            end
        end
    end
    self.lines = {}
end

---@return nil
function TextPanel:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local y = self.y
    for i = 1, #self.lines do
        local line = self.lines[i]
        local txt = type(line) == "table" and line.text or line
        love.graphics.printf(txt, self.x, y, self.w, "left")
        y = y + 18
    end
end

return TextPanel
