local Object = require("Engine.Core.Object")
local Vector2 = require("Engine.Utils.Vector2")

---@class Node : Object
---@field _pos Vector2
---@field w number
---@field h number
---@field sx number
---@field sy number
---@field pivotX number @锚点 X，范围 [0,1]，0 为左，1 为右
---@field pivotY number @锚点 Y，范围 [0,1]，0 为上，1 为下
---@field visible boolean
---@field children table
---@field parent Node|nil
local Node = Object:extend()

function Node:init(x, y, w, h)
    self._pos = Vector2(x or 0, y or 0)
    ---@deprecated 保留镜像字段以平滑过渡
    self.x = self._pos.x
    self.y = self._pos.y
    self.w = w or 0
    self.h = h or 0
    self.sx = 1
    self.sy = 1
    self.pivotX = 0
    self.pivotY = 0
    self.visible = true
    self.children = {}
    self.parent = nil
end

function Node:add(child)
    if not child then return end
    child.parent = self
    self.children[#self.children + 1] = child
    if child.onEnter then child:onEnter() end
    return self
end

--- 设置锚点（pivot），不改变现有行为（默认 0,0 即左上角）
---@param px number|nil @0..1，0 为左/上，1 为右/下
---@param py number|nil @0..1
---@return Node
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

function Node:remove(child)
    if not child then return end
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

function Node:setPosition(x, y)
    if x ~= nil then self._pos.x = x end
    if y ~= nil then self._pos.y = y end
    -- 同步镜像字段用于兼容
    self.x, self.y = self._pos.x, self._pos.y
    return self
end

function Node:getWorldPosition()
    local x, y = self._pos.x, self._pos.y
    local p = self.parent
    while p do
        local px, py = 0, 0
        if p._pos then px, py = p._pos.x, p._pos.y else px, py = (p.x or 0), (p.y or 0) end
        x = x + px
        y = y + py
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

--- 将局部坐标转换为世界坐标（仅平移叠加；与当前绘制保持一致）
---@param lx number
---@param ly number
---@return number, number
function Node:localToWorld(lx, ly)
    local wx, wy = lx + (self._pos.x or 0), ly + (self._pos.y or 0)
    local p = self.parent
    while p do
        local px, py = 0, 0
        if p._pos then px, py = p._pos.x, p._pos.y else px, py = (p.x or 0), (p.y or 0) end
        wx = wx + px
        wy = wy + py
        p = p.parent
    end
    return wx, wy
end

--- 将世界坐标转换为局部坐标（仅平移叠加；与当前绘制保持一致）
---@param wx number
---@param wy number
---@return number, number
function Node:worldToLocal(wx, wy)
    local lx, ly = wx, wy
    local chain = {}
    local p = self
    while p do
        chain[#chain+1] = p
        p = p.parent
    end
    for i = 1, #chain do
        local n = chain[i]
        if n._pos then
            lx = lx - (n._pos.x or 0)
            ly = ly - (n._pos.y or 0)
        else
            lx = lx - (n.x or 0)
            ly = ly - (n.y or 0)
        end
    end
    return lx, ly
end

--- 计算世界轴对齐包围盒（AABB）：返回 x,y,w,h，其中 w/h 应用组合缩放
---@return number, number, number, number
function Node:getWorldAABB()
    local x, y = self:getWorldPosition()
    local w = (self.w or 0)
    local h = (self.h or 0)
    local ox = (self.pivotX or 0) * w
    local oy = (self.pivotY or 0) * h
    return x - ox, y - oy, w, h
end

--- 以向量设置位置（便捷）
---@param v { x:number, y:number }
---@return Node
function Node:setPositionV(v)
    if v then
        self._pos.x = v.x or self._pos.x
        self._pos.y = v.y or self._pos.y
        -- 同步镜像字段
        self.x, self.y = self._pos.x, self._pos.y
    end
    return self
end

--- 获取本地位置（标量）
---@return number, number
function Node:getLocalPosition()
    return self._pos.x, self._pos.y
end

--- 获取本地位置（向量副本）
---@return Vector2
function Node:getPositionV()
    return Vector2(self._pos.x, self._pos.y)
end

--- 语法糖：设置中心锚点（0.5,0.5）
---@return Node
function Node:setPivotCenter()
    return self:setPivot(0.5, 0.5)
end

--- 语法糖：左上角锚点（0,0）
---@return Node
function Node:setPivotTopLeft()
    return self:setPivot(0, 0)
end

--- 语法糖：右上角锚点（1,0）
---@return Node
function Node:setPivotTopRight()
    return self:setPivot(1, 0)
end

--- 语法糖：左下角锚点（0,1）
---@return Node
function Node:setPivotBottomLeft()
    return self:setPivot(0, 1)
end

--- 语法糖：右下角锚点（1,1）
---@return Node
function Node:setPivotBottomRight()
    return self:setPivot(1, 1)
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