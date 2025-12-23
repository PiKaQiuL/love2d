-- Engine/Effects/EffectTree.lua
-- 效果树基础模块：通用效果节点与组合/装饰器
-- 模块：效果/技能/Buff
-- 功能：提供效果节点生命周期（apply/update/expire/tick/reset），支持父子结构与共享黑板，
--      以及常见节点：Parallel, Condition, Duration。
-- 依赖：Engine.Core.Object, Engine.Core.TreeNode
-- 作者：Team
-- 修改时间：2025-12-24

local Object = require("Engine.Core.Object")
local TreeNode = require("Engine.Core.TreeNode")

-- 效果状态枚举（与行为树类似，为简化沿用同名值）
local Status = {
    Idle = "idle",
    Running = "running",
    Success = "success",
    Failure = "failure",
}

---
---@class EffectNode : TreeNode
---@field status string
---@field started boolean
---@field blackboard table|nil
---@field children EffectNode[]
local EffectNode = TreeNode:extend()

function EffectNode:init(opts)
    TreeNode.init(self, opts)
    self.status = Status.Idle
    self.started = false
    self.blackboard = nil
end

function EffectNode:setBlackboard(bb)
    self.blackboard = bb
end

-- 生命周期钩子：子类实现
function EffectNode:apply(bb) end

---@param dt number
---@param bb table|nil
---@return string
function EffectNode:update(dt, bb)
    return Status.Success
end

---@param status string
---@param bb table|nil
function EffectNode:expire(status, bb) end

---@param dt number
---@param bb table|nil
---@return string
function EffectNode:tick(dt, bb)
    bb = bb or self.blackboard
    if not self.started then
        self.started = true
        self.status = Status.Running
        self:apply(bb)
    end
    local s = self:update(dt, bb)
    if s ~= Status.Running then
        self.status = s
        self:expire(s, bb)
        self.started = false
    else
        self.status = Status.Running
    end
    return self.status
end

function EffectNode:reset()
    self.status = Status.Idle
    self.started = false
    local ch = self.children ---@type EffectNode[]
    for i = 1, #ch do
        local c = ch[i]
        if c and c.reset then c:reset() end
    end
end

function EffectNode:abort()
    self.status = Status.Idle
    self.started = false
end

---
---@class EffectTree : Object
---@field root EffectNode
---@field blackboard table
---@field status string
local EffectTree = Object:extend()

function EffectTree:init(root, blackboard)
    self.root = root
    self.blackboard = blackboard or {}
    if self.root and self.root.setBlackboard then
        self.root:setBlackboard(self.blackboard)
    end
    self.status = Status.Idle
end

function EffectTree:setRoot(root)
    self.root = root
    if self.root and self.root.setBlackboard then
        self.root:setBlackboard(self.blackboard)
    end
end

function EffectTree:setBlackboard(bb)
    self.blackboard = bb or {}
    if self.root and self.root.setBlackboard then
        self.root:setBlackboard(self.blackboard)
    end
end

function EffectTree:tick(dt)
    if not self.root then return Status.Failure end
    local s = self.root:tick(dt, self.blackboard)
    self.status = s
    return s
end

function EffectTree:reset()
    self.status = Status.Idle
    if self.root and self.root.reset then self.root:reset() end
end

function EffectTree:getStatus()
    return self.status
end

-- 并行组合：所有子节点并行运行
---@class Parallel : EffectNode
local Parallel = EffectNode:extend()

function Parallel:update(dt, bb)
    local ch = self.children ---@type EffectNode[]
    if #ch == 0 then return Status.Success end
    local allSuccess = true
    for i = 1, #ch do
        local s = ch[i]:tick(dt, bb)
        if s == Status.Failure then return Status.Failure end
        if s == Status.Running then allSuccess = false end
    end
    if allSuccess then return Status.Success else return Status.Running end
end

-- 条件装饰器：条件为真才运行子节点
---@class Condition : EffectNode
---@field child EffectNode|nil
---@field predicate fun(bb:table):boolean
local Condition = EffectNode:extend()

function Condition:init(opts)
    EffectNode.init(self, opts)
    self.child = nil
    self.predicate = (opts and opts.predicate) or function() return true end
    if opts and opts.child then self:setChild(opts.child) end
end

function Condition:setChild(child)
    self:clear()
    self.child = child
    if child then self:add(child) end
end

function Condition:update(dt, bb)
    if not self.predicate(bb or self.blackboard) then
        return Status.Failure
    end
    if not self.child then return Status.Success end
    return self.child:tick(dt, bb)
end

function Condition:reset()
    EffectNode.reset(self)
    if self.child and self.child.reset then self.child:reset() end
end

-- 时长装饰器：运行指定时长后结束成功
---@class Duration : EffectNode
---@field child EffectNode|nil
---@field duration number
---@field elapsed number
local Duration = EffectNode:extend()

function Duration:init(opts)
    EffectNode.init(self, opts)
    self.child = nil
    self.duration = (opts and opts.duration) or 1.0
    self.elapsed = 0
    if opts and opts.child then self:setChild(opts.child) end
end

function Duration:setChild(child)
    self:clear()
    self.child = child
    if child then self:add(child) end
end

function Duration:apply(bb)
    self.elapsed = 0
    if self.child and self.child.reset then self.child:reset() end
end

function Duration:update(dt, bb)
    self.elapsed = self.elapsed + (dt or 0)
    if self.child then
        local s = self.child:tick(dt, bb)
        if s == Status.Failure then return Status.Failure end
        -- 即使子节点成功，也持续到时长结束
    end
    if self.elapsed >= self.duration then
        return Status.Success
    else
        return Status.Running
    end
end

function Duration:reset()
    EffectNode.reset(self)
    self.elapsed = 0
end

return {
    Status = Status,
    Node = EffectNode,
    Tree = EffectTree,
    Parallel = Parallel,
    Condition = Condition,
    Duration = Duration,
}
