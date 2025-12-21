-- Engine/Object.lua
-- Love2D OOP 基础对象库
-- 模块：对象基类
-- 功能：提供最小继承/实例化与类型判断
-- 依赖：Lua 元表机制
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 方法：
-- - new(...): 创建实例并调用 init
-- - extend(): 创建子类
-- - is(class): 类型判断（沿继承链）

---
---@class Object
---@field _bindings table|nil @内部事件绑定跟踪
---@field onDestroy fun(self:Object)|nil @可选销毁回调
local Object = {}
Object.__index = Object

-- 支持类调用直接实例化：MyClass(...) 等价于 MyClass:new(...)
-- 避免类表的元表指向自身，防止 __index 形成循环
setmetatable(Object, {
    __call = function(cls, ...)
        return cls:new(...)
    end
})

---@param ... unknown
function Object:init(...)
end

---@generic T
---@param ... any
---@return T
function Object:new(...)
    local instance = setmetatable({}, self)
    if instance.init then
        instance:init(...)
    end
    return instance
end

---
---@return table
function Object:extend()
    local subclass = {}
    for k, v in pairs(self) do
        if k:find("^__") then
            subclass[k] = v
        end
    end
    subclass.__index = subclass
    subclass.super = self
    -- 让子类在类级别索引父类，避免循环；并支持直接调用进行实例化
    setmetatable(subclass, {
        __index = self,
        __call = function(cls, ...)
            return cls:new(...)
        end
    })
    return subclass
end

---
---@param class table
---@return boolean
function Object:is(class)
    local mt = getmetatable(self)
    while mt do
        if mt == class then return true end
        mt = mt.super
    end
    return false
end

--- 绑定事件并自动跟踪，便于销毁时统一清理
---@param bus table @具有 on/off 方法的事件总线
---@param event string
---@param handler function
---@param opts table|nil
---@return function|nil @原始 handler，若绑定失败则为 nil
function Object:bindEvent(bus, event, handler, opts)
    if not bus or type(bus.on) ~= "function" then return nil end
    self._bindings = self._bindings or {}
    local h = bus:on(event, handler, opts)
    self._bindings[#self._bindings + 1] = { bus = bus, event = event, handler = h }
    return h
end

--- 取消通过 bindEvent 绑定的所有事件
function Object:unbindEvents()
    if not self._bindings then return end
    for i = #self._bindings, 1, -1 do
        local b = self._bindings[i]
        if b.bus and type(b.bus.off) == "function" then
            b.bus:off(b.event, b.handler)
        end
        table.remove(self._bindings, i)
    end
    self._bindings = nil
end

--- 对象销毁钩子：先清理事件，再调用 onDestroy
function Object:destroy()
    if self.unbindEvents then self:unbindEvents() end
    if type(self.onDestroy) == "function" then
        self:onDestroy()
    end
end

return Object
