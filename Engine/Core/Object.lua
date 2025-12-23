-- Engine/Object.lua
-- Love2D OOP 基础对象库
-- 模块：对象基类
-- 功能：提供最小继承/实例化与类型判断,支持 getter/setter
-- 依赖：Lua 元表机制
-- 作者：Team
-- 修改时间：2025-12-23
--
-- 方法：
-- - new(...): 创建实例并调用 init
-- - extend(): 创建子类
-- - is(class): 类型判断(沿继承链)
--
-- Getter/Setter 用法(通过直接赋值定义)：
-- 1. Getter: Class.__getter.propertyName = function(self) return value, needCache end
--    - needCache 为 true 时,结果会被缓存到实例上
-- 2. Setter: Class.__setter.propertyName = function(self, value) return processedValue end
--    - 返回 nil 表示不缓存,直接使用副作用
--    - 返回非 nil 值会缓存该值到实例上
--
-- 示例(参考 Node.lua)：
--   local MyClass = Object:extend()
--   MyClass.__getter.x = function(self)
--     return self.pos.x
--   end
--   MyClass.__setter.x = function(self, value)
--     self.pos.x = value
--   end
--
--   local obj = MyClass()
--   obj.x = 100  -- 调用 setter
--   print(obj.x) -- 调用 getter

---
---@class Object
---@field _bindings table|nil @内部事件绑定跟踪
---@field onDestroy fun(self:Object)|nil @可选销毁回调
---@field __getter table @getter 函数表
---@field __setter table @setter 函数表
---@overload fun(...):self
local Object = {}
Object.__getter = {}
Object.__setter = {}
Object.__index = Object

-- 支持类调用直接实例化：MyClass(...) 等价于 MyClass:new(...)
-- 避免类表的元表指向自身，防止 __index 形成循环
-- setmetatable(Object, {
--     __call = function(cls, ...)
--         return cls:new(...)
--     end
-- })

---@param ... unknown
function Object:init(...)
end

---@generic T
---@param ... any
---@return T
function Object:new(...)
    local instance = {}
    local class = self
    local getter = self.__getter
    local setter = self.__setter

    -- 创建实例专属的元表
    local mt = {}

    -- 设置 __index：优先查找 getter,然后查找类表
    if next(getter) then
        mt.__index = function(tbl, k)
            local f = getter[k]
            if f then
                local res, needCache = f(tbl)
                if needCache then
                    rawset(tbl, k, res)
                end
                return res
            else
                local r = class[k]
                if r ~= nil then
                    rawset(tbl, k, r)
                end
                return r
            end
        end
    else
        mt.__index = class
    end

    -- 设置 __newindex：如果有 setter 则使用 setter 函数
    if next(setter) then
        mt.__newindex = function(tbl, k, v)
            local f = setter[k]
            if f then
                local res = f(tbl, v)
                if res ~= nil then
                    rawset(tbl, k, res)
                end
            else
                rawset(tbl, k, v)
            end
        end
    end

    -- 传播类上的运算/显示等元方法到实例元表，使运算符重载生效
    local metaFns = {
        "__add", "__sub", "__mul", "__div", "__unm", "__len", "__eq", "__tostring"
    }
    for i = 1, #metaFns do
        local k = metaFns[i]
        if class[k] ~= nil then
            mt[k] = class[k]
        end
    end

    -- 让实例的元表也具备 super 链，便于 Object:is() 沿链判断类型
    mt.super = class

    setmetatable(instance, mt)

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

    -- 创建子类独立的 getter 和 setter 表
    subclass.__getter = {}
    subclass.__setter = {}

    -- 继承父类的 getter 和 setter
    for k, v in pairs(self.__getter) do
        subclass.__getter[k] = v
    end
    for k, v in pairs(self.__setter) do
        subclass.__setter[k] = v
    end

    subclass.__index = subclass
    subclass.super = self
    -- 让子类在类级别索引父类,避免循环;并支持直接调用进行实例化
    setmetatable(subclass, {
        __index = self,

        ---@generic T : Object
        ---@param cls T
        ---@param ... unknown
        ---@return T
        __call = function(cls, ...)
---@diagnostic disable-next-line: undefined-field
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

--- 对象销毁钩子:先清理事件,再调用 onDestroy
function Object:destroy()
    if self.unbindEvents then self:unbindEvents() end
    if type(self.onDestroy) == "function" then
        self:onDestroy()
    end
end

return Object
