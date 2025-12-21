-- Engine/Pool.lua
-- 通用对象池：减少频繁创建/销毁的开销
-- 模块：对象池
-- 功能：提供获取(acquire)/归还(release)/预热(prewarm)/清理(clear)等接口
-- 依赖：Engine.Object
-- 作者：Team
-- 修改时间：2025-12-22
--
-- 使用场景：
-- - 短生命周期对象（如临时 UI 节点、特效、列表项容器）
-- - 频繁重复使用但状态可重置的对象
--
-- 设计约定：
-- - factory(): 创建新对象（必填）
-- - reset(obj): 重置对象（可选；acquire 或 release 时调用）
-- - maxSize: 池上限（可选；超过不再保留）

local Object = require("Engine.Core.Object")

---
---@class Pool : Object
---@field _items table
---@field factory fun():any
---@field reset fun(obj:any)|nil
---@field maxSize number|nil
local Pool = Object:extend()

---
---@param opts table|nil @{ factory:function, reset:function|nil, maxSize:number|nil }
function Pool:init(opts)
    opts = opts or {}
    if type(opts.factory) ~= "function" then
        error("Pool:init requires opts.factory function")
    end
    self.factory = opts.factory
    self.reset = opts.reset
    self.maxSize = opts.maxSize and tonumber(opts.maxSize) or nil
    self._items = {}
end

--- 预热池，先创建并缓存若干对象
---@param n number
function Pool:prewarm(n)
    n = tonumber(n or 0) or 0
    for i = 1, n do
        local obj = self.factory()
        if self.reset then self.reset(obj) end
        self._items[#self._items + 1] = obj
    end
end

--- 获取对象：优先复用池中对象；若无则创建新对象
---@return any
function Pool:acquire()
    local obj
    if #self._items > 0 then
        obj = table.remove(self._items)
    else
        obj = self.factory()
    end
    if self.reset then self.reset(obj) end
    return obj
end

--- 归还对象：放回池中供复用；若超过上限则丢弃
---@param obj any
function Pool:release(obj)
    if obj == nil then return end
    if self.maxSize and #self._items >= self.maxSize then
        return -- 达上限不再保留
    end
    if self.reset then self.reset(obj) end
    self._items[#self._items + 1] = obj
end

--- 当前池大小
---@return number
function Pool:size()
    return #self._items
end

--- 清空池
function Pool:clear()
    self._items = {}
end

return Pool
