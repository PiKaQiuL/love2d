local Object = require("Engine.Core.Object")

---@class Node : Object
---@field x number
---@field y number
---@field w number
---@field h number
---@field sx number
---@field sy number
---@field visible boolean
---@field children table
---@field parent Node|nil
local Node = Object:extend()

function Node:init(x, y, w, h)
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    self.sx = 1
    self.sy = 1
    self.visible = true
    self.children = {}
    self.parent = nil
end

function Node:add(child)
    if not child then return end
    child.parent = self
    self.children[#self.children + 1] = child
    if child.onEnter then child:onEnter() end
end

function Node:remove(child)
    if not child then return end
    for i = 1, #self.children do
        if self.children[i] == child then
            table.remove(self.children, i)
            child.parent = nil
            if child.onExit then child:onExit() end
            return
        end
    end
end

function Node:setPosition(x, y)
    if x ~= nil then self.x = x end
    if y ~= nil then self.y = y end
end

function Node:getWorldPosition()
    local x, y = self.x, self.y
    local p = self.parent
    while p do
        x = x + (p.x or 0)
        y = y + (p.y or 0)
        p = p.parent
    end
    return x, y
end

function Node:update(dt)
    for i = 1, #self.children do
        local c = self.children[i]
        if c.update then c:update(dt) end
    end
end

function Node:draw()
    for i = 1, #self.children do
        local c = self.children[i]
        if c.draw then c:draw() end
    end
end

function Node:onEnter() end
function Node:onExit() end

return Node