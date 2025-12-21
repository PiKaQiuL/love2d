-- Engine/UI/Widget.lua
-- 通用控件基类：统一绘制/命中测试/可见性/启用/缩放等

local Node = require("Engine.Core.Node")

---@class Widget : Node
---@field w number
---@field h number
---@field enabled boolean
---@field opacity number
---@field render fun(self:Widget, x:number, y:number)|nil
---@field preRender fun(self:Widget, x:number, y:number)|nil
---@field postRender fun(self:Widget, x:number, y:number)|nil
local Widget = Node:extend()

---
---@param x number|nil
---@param y number|nil
---@param w number|nil
---@param h number|nil
---@param opts table|nil @{ enabled:boolean|nil, opacity:number|nil }
function Widget:init(x, y, w, h, opts)
    opts = opts or {}
    Node.init(self, x or 0, y or 0)
    self.w = w or 0
    self.h = h or 0
    self.enabled = opts.enabled ~= false
    self.opacity = opts.opacity or 1
end

function Widget:setSize(w, h)
    self.w, self.h = w or self.w, h or self.h
end

function Widget:setScale(sx, sy)
    self.sx = sx or self.sx or 1
    self.sy = sy or self.sy or 1
end

function Widget:setVisible(v)
    self.visible = not not v
end

function Widget:setEnabled(e)
    self.enabled = not not e
end

--- 简易命中测试：基于位置与尺寸
---@param mx number
---@param my number
---@return boolean
function Widget:hitTest(mx, my)
    if not self.visible then return false end
    local x, y = self:getWorldPosition()
    local w = (self.w or 0) * (self.sx or 1)
    local h = (self.h or 0) * (self.sy or 1)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

--- 统一绘制流程：先渲染自身，再绘制子节点
function Widget:draw()
    if not self.visible then return end
    local x, y = self:getWorldPosition()
    if type(self.preRender) == "function" then self:preRender(x, y) end
    if type(self.render) == "function" then self:render(x, y) end
    for i = 1, #self.children do
        local c = self.children[i]
        if c.draw then c:draw() end
    end
    if type(self.postRender) == "function" then self:postRender(x, y) end
end

return Widget