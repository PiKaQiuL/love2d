-- Engine/Core/TreeNode.lua
-- 通用树节点基类：名称、父子关系与基本操作
-- 模块：树节点
-- 功能：为行为树、效果树等提供最小通用父子结构
-- 依赖：Engine.Core.Object
-- 作者：Team
-- 修改时间：2025-12-24

local Object = require("Engine.Core.Object")

---
---@class TreeNode : Object
---@field name string|nil
---@field parent TreeNode|nil
---@field children TreeNode[]
local TreeNode = Object:extend()

---@param opts table|nil @{ name:string|nil, children:TreeNode[]|nil }
function TreeNode:init(opts)
    opts = opts or {}
    self.name = opts.name
    self.parent = nil
    self.children = {}
    local ch = opts.children
    if ch and type(ch) == "table" then
        for i = 1, #ch do
            self:add(ch[i])
        end
    end
end

---@param child TreeNode
function TreeNode:add(child)
    if not child or child == self then return end
    self.children[#self.children + 1] = child
    if child.setParent then child:setParent(self) else child.parent = self end
end

---@param index integer
---@param child TreeNode
function TreeNode:insert(index, child)
    if not child or child == self then return end
    if index < 1 then index = 1 end
    if index > #self.children + 1 then index = #self.children + 1 end
    table.insert(self.children, index, child)
    if child.setParent then child:setParent(self) else child.parent = self end
end

---@param child TreeNode
function TreeNode:remove(child)
    if not child then return end
    for i = 1, #self.children do
        if self.children[i] == child then
            table.remove(self.children, i)
            if child.setParent then child:setParent(nil) else child.parent = nil end
            return child
        end
    end
end

---@param index integer
function TreeNode:removeAt(index)
    if index < 1 or index > #self.children then return nil end
    local child = table.remove(self.children, index)
    if child then
        if child.setParent then child:setParent(nil) else child.parent = nil end
    end
    return child
end

function TreeNode:clear()
    for i = 1, #self.children do
        local c = self.children[i]
        if c then
            if c.setParent then c:setParent(nil) else c.parent = nil end
        end
    end
    self.children = {}
end

---@param p TreeNode|nil
function TreeNode:setParent(p)
    self.parent = p
end

function TreeNode:getParent()
    return self.parent
end

function TreeNode:getChildren()
    return self.children
end

-- 从父节点移除自身
function TreeNode:detach()
    local p = self.parent
    if not p or not p.children then
        self.parent = nil
        return false
    end
    for i = 1, #p.children do
        if p.children[i] == self then
            table.remove(p.children, i)
            self.parent = nil
            return true
        end
    end
    self.parent = nil
    return false
end

-- 获取根节点
function TreeNode:root()
    local n = self
    while n and n.parent do n = n.parent end
    return n
end

return TreeNode
