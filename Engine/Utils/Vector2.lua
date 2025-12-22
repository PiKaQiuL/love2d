-- Engine/Utils/Vector2.lua
-- 2D 向量类型，支持运算符重载与常用向量运算
-- 风格：与 Engine.Core.Object 一致，可直接调用构造：Vector2(x, y)
--
-- 用法示例：
--   local v  = Vector2(1, 2)
--   local w  = Vector2(3, 4)
--   local s  = v * w            -- 点积: 1*3 + 2*4 = 11
--   local u1 = v + w            -- 向量加法: (4, 6)
--   local u2 = 2 * v            -- 标量乘法: (2, 4)
--   local u3 = (v - w):normalized()
--   local d  = v:distance(w)    -- 欧氏距离
--
-- 乘法规则：
--   - number * Vector2 或 Vector2 * number => 向量缩放（返回 Vector2）
--   - Vector2 * Vector2 => 点积（返回 number）

local Object = require("Engine.Core.Object")

---
---@class Vector2 : Object
---@field x number
---@field y number
---@operator add(Vector2): Vector2
---@operator sub(Vector2): Vector2
---@operator mul(number): Vector2
---@operator mul(Vector2): number
---@operator div(number): Vector2
---@operator unm: Vector2
---@operator len: number
local Vector2 = Object:extend()

---
---@param x number|nil
---@param y number|nil
function Vector2:init(x, y)
    self.x = x or 0
    self.y = y or 0
end

--- 创建一个副本
---@return Vector2
function Vector2:copy()
    return Vector2(self.x, self.y)
end

--- 设定分量（可链式）
---@param x number
---@param y number
---@return Vector2
function Vector2:set(x, y)
    self.x = x; self.y = y
    return self
end

--- 向量长度平方（避免开方，适用于比较大小的场景）
---@return number
function Vector2:length2()
    return self.x * self.x + self.y * self.y
end

--- 向量长度
---@return number
function Vector2:length()
    return math.sqrt(self:length2())
end

--- 归一化（原地），零向量保持不变
---@return Vector2
function Vector2:normalize()
    local len = self:length()
    if len > 0 then self.x = self.x / len; self.y = self.y / len end
    return self
end

--- 返回已归一化的新向量
---@return Vector2
function Vector2:normalized()
    local len = self:length()
    if len > 0 then return Vector2(self.x / len, self.y / len) end
    return Vector2(0, 0)
end

--- 点积（投影/夹角计算常用）
---@param other Vector2
---@return number
function Vector2:dot(other)
    return self.x * other.x + self.y * other.y
end

--- 距离（欧氏）
---@param other Vector2
---@return number
function Vector2:distance(other)
    local dx = self.x - other.x
    local dy = self.y - other.y
    return math.sqrt(dx*dx + dy*dy)
end

---@param other Vector2
---@return number
function Vector2:distance2(other)
    local dx = self.x - other.x
    local dy = self.y - other.y
    return dx*dx + dy*dy
end

--- 线性插值：当 t∈[0,1] 时在 self 和 to 之间插值
---@param to Vector2
---@param t number
---@return Vector2
function Vector2:lerp(to, t)
    return Vector2(self.x + (to.x - self.x) * t, self.y + (to.y - self.y) * t)
end

--- 限制长度（原地），若长度超过 maxLen 则按比例缩放
---@param maxLen number
---@return Vector2
function Vector2:clampLength(maxLen)
    local len = self:length()
    if len > maxLen and len > 0 then
        local k = maxLen / len
        self.x = self.x * k
        self.y = self.y * k
    end
    return self
end

-- 运算符重载（实例元表在类表上）
--- 向量加法
---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2.__add(a, b)
    return Vector2(a.x + b.x, a.y + b.y)
end

--- 向量减法
---@param a Vector2
---@param b Vector2
---@return Vector2
function Vector2.__sub(a, b)
    return Vector2(a.x - b.x, a.y - b.y)
end

-- 乘法：数*向量、向量*数，或向量·向量（点积）
--- 多态乘法：
--- - number * Vector2 或 Vector2 * number => Vector2（缩放）
--- - Vector2 * Vector2 => number（点积）
---@param a any
---@param b any
---@return any
function Vector2.__mul(a, b)
    local ta, tb = type(a), type(b)
    if ta == "number" and getmetatable(b) == Vector2 then
        return Vector2(a * b.x, a * b.y)
    elseif tb == "number" and getmetatable(a) == Vector2 then
        return Vector2(a.x * b, a.y * b)
    elseif getmetatable(a) == Vector2 and getmetatable(b) == Vector2 then
        return a.x * b.x + a.y * b.y
    end
    error("Vector2.__mul: unsupported operands")
end

--- 标量除法：Vector2 / number
---@param a Vector2
---@param b number
---@return Vector2
function Vector2.__div(a, b)
    if type(b) == "number" then
        return Vector2(a.x / b, a.y / b)
    end
    error("Vector2.__div: divisor must be number")
end

--- 取反：-Vector2
---@param a Vector2
---@return Vector2
function Vector2.__unm(a)
    return Vector2(-a.x, -a.y)
end

--- 长度：#Vector2
---@param a Vector2
---@return number
function Vector2.__len(a)
    return a:length()
end

--- 相等比较：两个向量分量完全相等
---@param a Vector2
---@param b Vector2
---@return boolean
function Vector2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

--- 字符串表示
---@param a Vector2
---@return string
function Vector2.__tostring(a)
    return string.format("(%.3f, %.3f)", a.x, a.y)
end

-- 静态构造/常量
---@return Vector2
function Vector2.zero()
    return Vector2(0, 0)
end

---@return Vector2
function Vector2.one()
    return Vector2(1, 1)
end

---@return Vector2
function Vector2.unitX()
    return Vector2(1, 0)
end

---@return Vector2
function Vector2.unitY()
    return Vector2(0, 1)
end

--- 由极坐标构造
---@param angle number @弧度
---@param len number|nil @长度，默认 1
---@return Vector2
function Vector2.fromAngle(angle, len)
    local r = len or 1
    return Vector2(math.cos(angle) * r, math.sin(angle) * r)
end

return Vector2
