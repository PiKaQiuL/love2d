-- Engine/Timer.lua
-- 简单计时调度：一次与循环任务
-- 模块：计时与调度
-- 功能：一次/循环任务的时间推进与执行
-- 依赖：Engine.Object
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：回调执行使用 pcall 防止崩溃；如果任务量大，考虑分批执行或减少调度频率。
--
-- 方法：
-- - after(seconds, cb): 延时执行一次
-- - every(seconds, cb): 每隔指定秒数循环执行
-- - cancel(id): 取消任务
-- - update(dt): 推进计时器并执行到期任务
-- - clear(): 清空所有任务

local Object = require("Engine.Core.Object")

---
---@class Timer : Object
---@field _tasks table
---@field _nextId number
local Timer = Object:extend()

---
function Timer:init()
    self._tasks = {}
    self._nextId = 1
end

local function makeTask(id, delay, interval, repeatable, cb)
    return {
        id = id,
        timeLeft = delay,
        interval = interval,
        repeatable = repeatable,
        cb = cb,
        canceled = false
    }
end

---
---@param seconds number
---@param cb function
---@return number
function Timer:after(seconds, cb)
    local id = self._nextId
    self._nextId = id + 1
    local task = makeTask(id, seconds, 0, false, cb)
    self._tasks[#self._tasks + 1] = task
    return id
end

---
---@param seconds number
---@param cb function
---@return number
function Timer:every(seconds, cb)
    local id = self._nextId
    self._nextId = id + 1
    local task = makeTask(id, seconds, seconds, true, cb)
    self._tasks[#self._tasks + 1] = task
    return id
end

---
---@param id number
---@return boolean|nil
function Timer:cancel(id)
    for i = #self._tasks, 1, -1 do
        if self._tasks[i].id == id then
            table.remove(self._tasks, i)
            return true
        end
    end
    return false
end

---
---@param dt number
function Timer:update(dt)
    if not dt or dt <= 0 then return end
    for i = #self._tasks, 1, -1 do
        local t = self._tasks[i]
        if not t.canceled then
            t.timeLeft = t.timeLeft - dt
            if t.timeLeft <= 0 then
                -- 运行回调，保护性调用
                local ok, err = pcall(t.cb)
                if not ok then
                    print("Timer callback error:", err)
                end
                if t.repeatable then
                    t.timeLeft = t.interval
                else
                    table.remove(self._tasks, i)
                end
            end
        end
    end
end

function Timer:clear()
    self._tasks = {}
end

return Timer
