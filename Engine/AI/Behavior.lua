-- Engine/AI/Behavior.lua
-- 行为树基础模块：状态枚举、节点基类与行为树封装
-- 模块：行为树
-- 功能：提供行为树节点生命周期（start/update/finish/tick/reset），支持父子结构与共享黑板。
-- 依赖：Engine.Core.Object
-- 作者：Team
-- 修改时间：2025-12-24

local Object = require("Engine.Core.Object")
local TreeNode = require("Engine.Core.TreeNode")

--- 行为状态枚举（保持轻量，避免全局修改 Enums）
local Status = {
    Idle = "idle",
    Running = "running",
    Success = "success",
    Failure = "failure",
}

---
---@class BehaviorNode : TreeNode
---@field name string|nil
---@field parent BehaviorNode|nil
---@field children BehaviorNode[]|nil
---@field status string -- one of Status
---@field started boolean
---@field blackboard table|nil
local BehaviorNode = TreeNode:extend()

---@param opts table|nil @{ name:string|nil, children:BehaviorNode[]|nil }
function BehaviorNode:init(opts)
    TreeNode.init(self, opts)
    self.status = Status.Idle
    self.started = false
    self.blackboard = nil
end

---@param bb table|nil
function BehaviorNode:setBlackboard(bb)
    self.blackboard = bb
end

-- 生命周期钩子：子类可重写
---@param bb table|nil
function BehaviorNode:start(bb)
    -- 默认无操作
end

---@param dt number
---@param bb table|nil
---@return string status
function BehaviorNode:update(dt, bb)
    -- 默认立即成功；叶子可重写为异步/耗时逻辑返回 Running
    return Status.Success
end

---@param status string
---@param bb table|nil
function BehaviorNode:finish(status, bb)
    -- 默认无操作
end

-- 每帧推进节点：处理首次进入、循环 update、结束回调
---@param dt number
---@param bb table|nil
---@return string status
function BehaviorNode:tick(dt, bb)
    bb = bb or self.blackboard
    if not self.started then
        self.started = true
        self.status = Status.Running
        self:start(bb)
    end

    local s = self:update(dt, bb)
    if s ~= Status.Running then
        self.status = s
        self:finish(s, bb)
        self.started = false
    else
        self.status = Status.Running
    end
    return self.status
end

-- 重置节点（包括递归重置子节点）
function BehaviorNode:reset()
    self.status = Status.Idle
    self.started = false
    if self.children then
        for i = 1, #self.children do
            local c = self.children[i]
            if c and c.reset then c:reset() end
        end
    end
end

-- 立即中止运行（不触发 finish 钩子），常用于外部打断
function BehaviorNode:abort()
    self.status = Status.Idle
    self.started = false
end

---
---@class BehaviorTree : Object
---@field root BehaviorNode
---@field blackboard table
---@field status string
local BehaviorTree = Object:extend()

---@param root BehaviorNode
---@param blackboard table|nil
function BehaviorTree:init(root, blackboard)
    self.root = root
    self.blackboard = blackboard or {}
    if self.root and self.root.setBlackboard then
        self.root:setBlackboard(self.blackboard)
    end
    self.status = Status.Idle
end

function BehaviorTree:setRoot(root)
    self.root = root
    if self.root and self.root.setBlackboard then
        self.root:setBlackboard(self.blackboard)
    end
end

function BehaviorTree:setBlackboard(bb)
    self.blackboard = bb or {}
    if self.root and self.root.setBlackboard then
        self.root:setBlackboard(self.blackboard)
    end
end

---@param dt number
---@return string status
function BehaviorTree:tick(dt)
    if not self.root then return Status.Failure end
    local s = self.root:tick(dt, self.blackboard)
    self.status = s
    return s
end

function BehaviorTree:reset()
    self.status = Status.Idle
    if self.root and self.root.reset then self.root:reset() end
end

function BehaviorTree:getStatus()
    return self.status
end

-- 组合节点：Sequence（依次执行所有子节点）
---@class Sequence : BehaviorNode
---@field index integer
local Sequence = BehaviorNode:extend()

function Sequence:init(opts)
    BehaviorNode.init(self, opts)
    self.index = 1
end

function Sequence:start(bb)
    self.index = 1
    -- 可选：重置所有子节点，确保从头开始
    if self.children then
        for i = 1, #self.children do
            local c = self.children[i]
            if c and c.reset then c:reset() end
        end
    end
end

function Sequence:update(dt, bb)
    local n = #self.children
    if n == 0 then return Status.Success end
    while self.index <= n do
        local child = self.children[self.index]
        local s = child:tick(dt, bb)
        if s == Status.Running then
            return Status.Running
        elseif s == Status.Failure then
            return Status.Failure
        else -- Success，尝试下一个
            self.index = self.index + 1
        end
    end
    return Status.Success
end

function Sequence:reset()
    BehaviorNode.reset(self)
    self.index = 1
end

-- 组合节点：Selector（从左到右挑选第一个成功的子节点）
---@class Selector : BehaviorNode
---@field index integer
local Selector = BehaviorNode:extend()

function Selector:init(opts)
    BehaviorNode.init(self, opts)
    self.index = 1
end

function Selector:start(bb)
    self.index = 1
    -- 可选：重置所有子节点
    if self.children then
        for i = 1, #self.children do
            local c = self.children[i]
            if c and c.reset then c:reset() end
        end
    end
end

function Selector:update(dt, bb)
    local n = #self.children
    if n == 0 then return Status.Failure end
    while self.index <= n do
        local child = self.children[self.index]
        local s = child:tick(dt, bb)
        if s == Status.Running then
            return Status.Running
        elseif s == Status.Success then
            return Status.Success
        else -- Failure，尝试下一个
            self.index = self.index + 1
        end
    end
    return Status.Failure
end

function Selector:reset()
    BehaviorNode.reset(self)
    self.index = 1
end

-- 装饰器：Inverter（反转成功与失败）
---@class Inverter : BehaviorNode
---@field child BehaviorNode|nil
local Inverter = BehaviorNode:extend()

function Inverter:init(opts)
    BehaviorNode.init(self, opts)
    self.child = nil
    if opts and opts.child then self:setChild(opts.child) end
end

function Inverter:setChild(child)
    self:clear()
    self.child = child
    if child then self:add(child) end
end

function Inverter:update(dt, bb)
    if not self.child then return Status.Success end
    local s = self.child:tick(dt, bb)
    if s == Status.Running then return Status.Running end
    if s == Status.Success then return Status.Failure end
    if s == Status.Failure then return Status.Success end
    return Status.Failure
end

function Inverter:reset()
    BehaviorNode.reset(self)
    if self.child and self.child.reset then self.child:reset() end
end

-- 装饰器：Repeater（重复执行子节点，达到次数后成功）
---@class Repeater : BehaviorNode
---@field child BehaviorNode|nil
---@field count integer|nil
---@field done integer
local Repeater = BehaviorNode:extend()

function Repeater:init(opts)
    BehaviorNode.init(self, opts)
    self.child = nil
    self.count = opts and opts.count or nil
    self.done = 0
    if opts and opts.child then self:setChild(opts.child) end
end

function Repeater:setChild(child)
    self:clear()
    self.child = child
    if child then self:add(child) end
end

function Repeater:start(bb)
    self.done = 0
    if self.child and self.child.reset then self.child:reset() end
end

function Repeater:update(dt, bb)
    if not self.child then return Status.Success end
    local s = self.child:tick(dt, bb)
    if s == Status.Running then return Status.Running end
    -- 子节点已结束，增加计数并重置子节点以便下一次执行
    self.done = self.done + 1
    if self.child.reset then self.child:reset() end
    if self.count and self.done >= self.count then
        return Status.Success
    else
        return Status.Running
    end
end

function Repeater:reset()
    BehaviorNode.reset(self)
    self.done = 0
end

return {
    Status = Status,
    Node = BehaviorNode,
    Tree = BehaviorTree,
    Sequence = Sequence,
    Selector = Selector,
    Inverter = Inverter,
    Repeater = Repeater,
}
