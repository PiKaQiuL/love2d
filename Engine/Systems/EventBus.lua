-- Engine/EventBus.lua
-- 轻量事件总线：发布/订阅/一次性订阅，支持优先级与目标暂停
--
-- 方法：
-- - on(event, handler, opts?): 订阅事件（opts: { priority:number, target:any }）
-- - once(event, handler, opts?): 一次性订阅（同上）
-- - off(event, handler?): 取消订阅，省略 handler 则移除该事件所有监听
-- - offTarget(target): 取消某个目标的所有监听
-- - pauseTarget(target): 暂停某个目标的监听
-- - resumeTarget(target): 恢复某个目标的监听
-- - emit(event, ...): 触发事件并传递参数；若监听函数返回 true，则停止后续传播
-- - clear(): 清空所有监听

local Object = require("Engine.Core.Object")

---
---@class EventBus : Object
---@field _listeners table
local EventBus = Object:extend()

---
function EventBus:init()
    self._listeners = {}
end

---
---@param event string
---@param handler function
---@param opts table|nil @{ priority:number, target:any }
function EventBus:on(event, handler, opts)
    if type(handler) ~= "function" then return end
    opts = opts or {}
    local list = self._listeners[event]
    if not list then
        list = {}
        self._listeners[event] = list
    end
    list[#list + 1] = {
        fn = handler,
        once = false,
        priority = tonumber(opts.priority or 0) or 0,
        target = opts.target,
        paused = false
    }
    table.sort(list, function(a, b) return (a.priority or 0) > (b.priority or 0) end)
    return handler
end

---
---@param event string
---@param handler function
---@param opts table|nil @{ priority:number, target:any }
function EventBus:once(event, handler, opts)
    if type(handler) ~= "function" then return end
    opts = opts or {}
    local list = self._listeners[event]
    if not list then
        list = {}
        self._listeners[event] = list
    end
    list[#list + 1] = {
        fn = handler,
        once = true,
        priority = tonumber(opts.priority or 0) or 0,
        target = opts.target,
        paused = false
    }
    table.sort(list, function(a, b) return (a.priority or 0) > (b.priority or 0) end)
    return handler
end

---
---@param event string
---@param handler function|nil
function EventBus:off(event, handler)
    local list = self._listeners[event]
    if not list then return end
    if not handler then
        self._listeners[event] = nil
        return
    end
    for i = #list, 1, -1 do
        if list[i].fn == handler then
            table.remove(list, i)
        end
    end
    if #list == 0 then self._listeners[event] = nil end
end

--- 取消某个目标的所有监听
---@param target any
function EventBus:offTarget(target)
    if target == nil then return end
    for event, list in pairs(self._listeners) do
        for i = #list, 1, -1 do
            if list[i].target == target then
                table.remove(list, i)
            end
        end
        if #list == 0 then self._listeners[event] = nil end
    end
end

--- 暂停某个目标的监听
---@param target any
function EventBus:pauseTarget(target)
    if target == nil then return end
    for _, list in pairs(self._listeners) do
        for i = 1, #list do
            local item = list[i]
            if item.target == target then
                item.paused = true
            end
        end
    end
end

--- 恢复某个目标的监听
---@param target any
function EventBus:resumeTarget(target)
    if target == nil then return end
    for _, list in pairs(self._listeners) do
        for i = 1, #list do
            local item = list[i]
            if item.target == target then
                item.paused = false
            end
        end
    end
end

---
---@param event string
---@param ... any
function EventBus:emit(event, ...)
    local list = self._listeners[event]
    if not list or #list == 0 then return end
    -- 拷贝，避免回调中修改当前列表导致迭代问题
    local snapshot = {}
    for i = 1, #list do snapshot[i] = list[i] end
    for i = 1, #snapshot do
        local item = snapshot[i]
        if not item.paused then
            local stop = item.fn(...)
            if item.once then
                self:off(event, item.fn)
            end
            if stop == true then
                break -- 监听返回 true 则停止传播
            end
        end
    end
end

function EventBus:clear()
    self._listeners = {}
end

return EventBus
