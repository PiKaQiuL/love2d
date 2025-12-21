-- Engine/Trigger.lua
-- 触发系统：支持条件/阈值触发、一次性/冷却、启停与事件广播
-- 模块：触发系统
-- 功能：按条件或阈值执行动作并支持冷却与一次性
-- 依赖：Engine.System
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：触发器数量较多时，建议按优先级或分组更新；条件函数中避免重计算或 IO。
--
-- 方法：
-- - add(name, opts): 添加通用触发器（condition/action/once/cooldown/...）
-- - addThreshold(name, getter, cmpOp, value, action, opts): 添加阈值触发器
-- - enable/disable(name): 启用/禁用触发器
-- - setCooldown(name, seconds): 设置冷却
-- - remove/clear: 移除或清空触发器
-- - fire(name, ctx): 手动触发（忽略条件与冷却）
-- - update(dt): 推进冷却并按条件触发，事件广播 `trigger:fired`

local System = require("Engine.Core.System")

---
---@class Trigger : System
---@field _items table
---@field _index table
local Trigger = System:extend()

---
function Trigger:init()
    self._items = {}
    self._index = {} -- name -> item
end

local function cmp(a, op, b)
    if op == ">" then return a > b
    elseif op == ">=" then return a >= b
    elseif op == "<" then return a < b
    elseif op == "<=" then return a <= b
    elseif op == "==" then return a == b
    elseif op == "~=" then return a ~= b
    else return false end
end

-- 添加一个通用触发器
-- opts: { condition=function(ctx) return boolean end, action=function(ctx) end, once=true, cooldown=0, enabled=true, data=any, priority=0 }
---
---@param name string
---@param opts table
---@return string
function Trigger:add(name, opts)
    opts = opts or {}
    if not name or type(opts.action) ~= "function" then
        error("Trigger:add requires name and action function")
    end
    local item = {
        name = name,
        condition = opts.condition, -- 可选；若为空则总是可触发（受冷却限制）
        action = opts.action,
        once = (opts.once ~= false),
        cooldown = tonumber(opts.cooldown or 0) or 0,
        remain = 0,
        enabled = (opts.enabled ~= false),
        data = opts.data,
        priority = tonumber(opts.priority or 0) or 0
    }
    self._items[#self._items + 1] = item
    self._index[name] = item
    return name
end

-- 便捷：基于数值阈值的触发
-- getter: function() -> number, cmpOp: "<"|"<="|">"|">="|"=="|"~="
function Trigger:addThreshold(name, getter, cmpOp, value, action, opts)
    if type(getter) ~= "function" then error("addThreshold requires getter function") end
    local condition = function(ctx)
        local v = getter()
        return cmp(v, cmpOp, value)
    end
    return self:add(name, {
        condition = condition,
        action = action,
        once = opts and opts.once,
        cooldown = opts and opts.cooldown,
        enabled = (not opts) or (opts.enabled ~= false),
        data = opts and opts.data,
        priority = opts and opts.priority or 0
    })
end

function Trigger:enable(name)
    local it = self._index[name]
    if it then it.enabled = true end
end

function Trigger:disable(name)
    local it = self._index[name]
    if it then it.enabled = false end
end

function Trigger:setCooldown(name, seconds)
    local it = self._index[name]
    if it then it.cooldown = tonumber(seconds or 0) or 0 end
end

function Trigger:remove(name)
    local it = self._index[name]
    if not it then return false end
    self._index[name] = nil
    for i = #self._items, 1, -1 do
        if self._items[i] == it then
            table.remove(self._items, i)
            return true
        end
    end
    return false
end

function Trigger:clear()
    self._items = {}
    self._index = {}
end

-- 手动触发（忽略条件与冷却，可选 context）
function Trigger:fire(name, context)
    local it = self._index[name]
    if not it or not it.enabled then return false end
    local ctx = context or { app = self.app, data = it.data }
    local ok, err = pcall(it.action, ctx)
    if not ok then print("Trigger action error:", err) end
    if self.app and self.app.emit then
        self.app:emit("trigger:fired", name, it)
    end
    if it.once then it.enabled = false end
    it.remain = it.cooldown or 0
    return true
end

function Trigger:update(dt)
    if dt and dt > 0 then
        for i = 1, #self._items do
            local it = self._items[i]
            if it.enabled then
                -- 冷却递减
                if it.remain and it.remain > 0 then
                    it.remain = it.remain - dt
                end
                local ready = (not it.remain) or (it.remain <= 0)
                if ready then
                    local ctx = { app = self.app, data = it.data }
                    local ok, res
                    if type(it.condition) == "function" then
                        ok, res = pcall(it.condition, ctx)
                        if not ok then
                            print("Trigger condition error:", res)
                            res = false
                        end
                    else
                        res = true -- 无条件则视为满足（受冷却限制）
                    end
                    if res then
                        local aok, aerr = pcall(it.action, ctx)
                        if not aok then print("Trigger action error:", aerr) end
                        if self.app and self.app.emit then
                            self.app:emit("trigger:fired", it.name, it)
                        end
                        if it.once then
                            it.enabled = false
                        end
                        it.remain = it.cooldown or 0
                    end
                end
            end
        end
    end
end

return Trigger
