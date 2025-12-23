local Object = require("Engine.Core.Object")
local Vector2 = require("Engine.Utils.Vector2")

---@class Node : Object
---@field pos Vector2 @节点位置
---@field lpos Vector2 @本地位置(用于某些计算)
---@field w number @宽度
---@field h number @高度
---@field sx number @X轴缩放
---@field sy number @Y轴缩放
---@field pivotX number @锚点 X，范围 [0,1]，0 为左，1 为右
---@field pivotY number @锚点 Y，范围 [0,1]，0 为上，1 为下
---@field visible boolean @可见性
---@field children Node[] @子节点列表
---@field parent Node|nil @父节点
---@overload fun(...):self
local Node = Object:extend()


--region Getter Setter
Node.__getter.x = function(self)
    return self.pos.x
end
Node.__getter.y = function(self)
    return self.pos.y
end
Node.__setter.x = function(self, value)
    self.pos.x = value
end
Node.__setter.y = function(self, value)
    self.pos.y = value
end
--endregion

function Node:init()
    self.pos = Vector2(0, 0)
    self.lpos = Vector2(0, 0)
    self.w = 0
    self.h = 0
    self.sx = 1
    self.sy = 1
    self.pivotX = 0
    self.pivotY = 0
    self.visible = true
    self.children = {}
    self.parent = nil
end


---添加子节点
---@generic T : Node
---
---@param child Node
---@return T
function Node:add(child)
    if not child then return self end
    child.parent = self
    self.children[#self.children + 1] = child
    if child.onEnter then child:onEnter() end
    return self
end

--- 设置锚点（pivot），不改变现有行为（默认 0,0 即左上角）
---@generic T : Node
---@param px number|nil @0..1，0 为左/上，1 为右/下
---@param py number|nil @0..1
---@return T
function Node:setPivot(px, py)
    if px ~= nil then
        if px < 0 then px = 0 elseif px > 1 then px = 1 end
        self.pivotX = px
    end
    if py ~= nil then
        if py < 0 then py = 0 elseif py > 1 then py = 1 end
        self.pivotY = py
    end
    return self
end

---移除子节点
---@generic T : Node
---
---@param child Node
---@return T
function Node:remove(child)
    if not child then return self end
    for i = 1, #self.children do
        if self.children[i] == child then
            table.remove(self.children, i)
            child.parent = nil
            if child.onExit then child:onExit() end
            return self
        end
    end
    return self
end

---设置节点位置
---@generic T : Node
---@param self T
---@param x number|nil
---@param y number|nil
---@return T
function Node:setPosition(x, y)
    ---@cast self Node
    if x ~= nil then self.pos.x = x end
    if y ~= nil then self.pos.y = y end
    return self
end

---获取世界坐标位置
---@return number, number
function Node:getWorldPosition()
    local x, y = self.pos.x, self.pos.y
    local p = self.parent
    while p do
        x = x + p.pos.x
        y = y + p.pos.y
        p = p.parent
    end
    return x, y
end

--- 组合获得从根到当前的缩放（不影响现有绘制，仅用于几何计算）
---@return number, number
function Node:getWorldScale()
    local sx, sy = self.sx or 1, self.sy or 1
    local p = self.parent
    while p do
        sx = sx * (p.sx or 1)
        sy = sy * (p.sy or 1)
        p = p.parent
    end
    return sx, sy
end

---将局部坐标转换为世界坐标（仅平移叠加）
---@param lx number
---@param ly number
---@return number, number
function Node:localToWorld(lx, ly)
    local wx, wy = lx + self.pos.x, ly + self.pos.y
    local p = self.parent
    while p do
        wx = wx + p.pos.x
        wy = wy + p.pos.y
        p = p.parent
    end
    return wx, wy
end

---将世界坐标转换为局部坐标（仅平移叠加）
---@param wx number
---@param wy number
---@return number, number
function Node:worldToLocal(wx, wy)
    local lx, ly = wx, wy
    local chain = {}
    local p = self
    while p do
        chain[#chain + 1] = p
        p = p.parent
    end
    for i = #chain, 1, -1 do
        local n = chain[i]
        lx = lx - n.pos.x
        ly = ly - n.pos.y
    end
    return lx, ly
end

---计算世界轴对齐包围盒（AABB）
---@return number x @左上角 X
---@return number y @左上角 Y
---@return number w @宽度
---@return number h @高度
function Node:getWorldAABB()
    local x, y = self:getWorldPosition()
    local w, h = self.w, self.h
    local ox = self.pivotX * w
    local oy = self.pivotY * h
    return x - ox, y - oy, w, h
end

---以向量设置位置
---@generic T : Node
---
---@param v Vector2|{x:number, y:number}
---@return T
function Node:setPositionV(v)
    if v then
        if v.x then self.pos.x = v.x end
        if v.y then self.pos.y = v.y end
    end
    return self
end

--- 获取本地位置（标量）
---@return number, number
function Node:getLocalPosition()
    return self.pos.x, self.pos.y
end

--- 获取本地位置（向量副本）
---@return Vector2
function Node:getPositionV()
    return Vector2(self.pos.x, self.pos.y)
end

--- 语法糖：设置中心锚点（0.5,0.5）
---@generic T : Node
---
---@return T
function Node:setPivotCenter()
    return self:setPivot(0.5, 0.5)
end

--- 语法糖：左上角锚点（0,0）
---@generic T : Node
---
---@return T
function Node:setPivotTopLeft()
    return self:setPivot(0, 0)
end

--- 语法糖：右上角锚点（1,0）
---@generic T : Node
---
---@return T
function Node:setPivotTopRight()
    return self:setPivot(1, 0)
end

--- 语法糖：左下角锚点（0,1）
---@generic T : Node
---
---@return T
function Node:setPivotBottomLeft()
    return self:setPivot(0, 1)
end

--- 语法糖：右下角锚点（1,1）
---@generic T : Node
---
---@return T
function Node:setPivotBottomRight()
    return self:setPivot(1, 1)
end

---更新节点及其子节点
---@param dt number
function Node:update(dt)
    for i = 1, #self.children do
        local c = self.children[i]
        if c.update then c:update(dt) end
    end
end

---绘制节点及其子节点
function Node:draw()
    for i = 1, #self.children do
        local c = self.children[i]
        if c.draw then c:draw() end
    end
end

function Node:onEnter() end
function Node:onExit() end

return Node