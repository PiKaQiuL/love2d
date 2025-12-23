-- Engine/Utils/Color.lua
-- 颜色工具类：提供颜色创建、转换、运算和预设颜色
-- 模块：颜色工具
-- 功能：RGB/HSV/Hex 转换、颜色混合、插值、预设颜色库
-- 依赖：Engine.Core.Object
-- 作者：Team
-- 修改时间：2025-12-23

local Object = require("Engine.Core.Object")

---@class Color : Object
---@field r number @红色分量 [0-1]
---@field g number @绿色分量 [0-1]
---@field b number @蓝色分量 [0-1]
---@field a number @透明度 [0-1]
---@overload fun(r:number|table|string|nil, g:number|nil, b:number|nil, a:number|nil):Color
local Color = Object:extend()

--- 初始化颜色
---@param r number|table|string|nil @红色分量 [0-1]，或颜色表 {r,g,b,a}，或十六进制字符串 "#RRGGBB"
---@param g number|nil @绿色分量 [0-1]
---@param b number|nil @蓝色分量 [0-1]
---@param a number|nil @透明度 [0-1]，默认 1
function Color:init(r, g, b, a)
    if type(r) == "table" then
        -- 从表初始化 {r,g,b,a} 或 {1,2,3,4}
        self.r = r.r or r[1] or 0
        self.g = r.g or r[2] or 0
        self.b = r.b or r[3] or 0
        self.a = r.a or r[4] or 1
    elseif type(r) == "string" then
        -- 从十六进制字符串初始化 "#RGB" "#RRGGBB" "#RRGGBBAA"
        local c = Color.fromHex(r)
        self.r, self.g, self.b, self.a = c.r, c.g, c.b, c.a
    else
        self.r = r or 0
        self.g = g or 0
        self.b = b or 0
        self.a = a or 1
    end
end

--- 转换为数组 {r, g, b, a}
---@return number[]
function Color:toArray()
    return { self.r, self.g, self.b, self.a }
end

--- 转换为表 {r, g, b, a}（别名）
---@return number[]
function Color:toTable()
    return self:toArray()
end

--- 转换为十六进制字符串 "#RRGGBB" 或 "#RRGGBBAA"
---@param includeAlpha boolean|nil @是否包含透明度，默认仅在 a < 1 时包含
---@return string
function Color:toHex(includeAlpha)
    local r = math.floor(self.r * 255 + 0.5)
    local g = math.floor(self.g * 255 + 0.5)
    local b = math.floor(self.b * 255 + 0.5)
    local a = math.floor(self.a * 255 + 0.5)
    
    if includeAlpha or (includeAlpha == nil and self.a < 1) then
        return string.format("#%02X%02X%02X%02X", r, g, b, a)
    else
        return string.format("#%02X%02X%02X", r, g, b)
    end
end

--- 转换为 HSV
---@return number h @色相 [0-360]
---@return number s @饱和度 [0-1]
---@return number v @明度 [0-1]
function Color:toHSV()
    local r, g, b = self.r, self.g, self.b
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    
    local h, s, v = 0, 0, max
    
    if max > 0 then
        s = delta / max
    end
    
    if delta > 0 then
        if max == r then
            h = 60 * (((g - b) / delta) % 6)
        elseif max == g then
            h = 60 * (((b - r) / delta) + 2)
        else
            h = 60 * (((r - g) / delta) + 4)
        end
    end
    
    return h, s, v
end

--- 克隆颜色
---@generic T : Color
---@param self T
---@return T
function Color:clone()
    return Color(self.r, self.g, self.b, self.a)
end

--- 设置颜色分量
---@generic T : Color
---@param self T
---@param r number|nil
---@param g number|nil
---@param b number|nil
---@param a number|nil
---@return T
function Color:set(r, g, b, a)
    if r then self.r = r end
    if g then self.g = g end
    if b then self.b = b end
    if a then self.a = a end
    return self
end

--- 设置透明度
---@generic T : Color
---@param self T
---@param a number
---@return T
function Color:setAlpha(a)
    self.a = a
    return self
end

--- 颜色插值（线性混合）
---@param other Color|table @目标颜色
---@param t number @插值因子 [0-1]，0 为当前颜色，1 为目标颜色
---@return Color @新颜色
function Color:lerp(other, t)
    local or_, og, ob, oa
    if type(other) == "table" then
        or_ = other.r or other[1] or 0
        og = other.g or other[2] or 0
        ob = other.b or other[3] or 0
        oa = other.a or other[4] or 1
    else
        or_, og, ob, oa = other.r, other.g, other.b, other.a
    end
    return Color(
        self.r + (or_ - self.r) * t,
        self.g + (og - self.g) * t,
        self.b + (ob - self.b) * t,
        self.a + (oa - self.a) * t
    )
end

--- 颜色混合（加法）
---@param other Color|table
---@return Color
function Color:add(other)
    local or_, og, ob, oa
    if type(other) == "table" then
        or_ = other.r or other[1] or 0
        og = other.g or other[2] or 0
        ob = other.b or other[3] or 0
        oa = other.a or other[4] or 1
    else
        or_, og, ob, oa = other.r, other.g, other.b, other.a
    end
    return Color(
        math.min(self.r + or_, 1),
        math.min(self.g + og, 1),
        math.min(self.b + ob, 1),
        math.min(self.a + oa, 1)
    )
end

--- 颜色混合（乘法）
---@param other Color|table
---@return Color
function Color:multiply(other)
    local or_, og, ob, oa
    if type(other) == "table" then
        or_ = other.r or other[1] or 0
        og = other.g or other[2] or 0
        ob = other.b or other[3] or 0
        oa = other.a or other[4] or 1
    else
        or_, og, ob, oa = other.r, other.g, other.b, other.a
    end
    return Color(
        self.r * or_,
        self.g * og,
        self.b * ob,
        self.a * oa
    )
end

--- 调整亮度
---@param factor number @亮度因子，>1 变亮，<1 变暗
---@return Color
function Color:brightness(factor)
    return Color(
        math.min(self.r * factor, 1),
        math.min(self.g * factor, 1),
        math.min(self.b * factor, 1),
        self.a
    )
end

--- 反色
---@return Color
function Color:invert()
    return Color(1 - self.r, 1 - self.g, 1 - self.b, self.a)
end

--- 灰度化
---@return Color
function Color:grayscale()
    local gray = self.r * 0.299 + self.g * 0.587 + self.b * 0.114
    return Color(gray, gray, gray, self.a)
end

--- 应用到 love.graphics
function Color:apply()
    love.graphics.setColor(self.r, self.g, self.b, self.a)
end

--- 字符串表示
---@return string
function Color:__tostring()
    return string.format("Color(%.2f, %.2f, %.2f, %.2f)", self.r, self.g, self.b, self.a)
end

-- ========== 静态方法 ==========

--- 从十六进制字符串创建颜色
---@param hex string @"#RGB" "#RRGGBB" "#RRGGBBAA"
---@return Color
function Color.fromHex(hex)
    hex = hex:gsub("#", "")
    local len = #hex
    local r, g, b, a = 0, 0, 0, 1
    
    if len == 3 then
        -- #RGB
        r = tonumber(hex:sub(1, 1) .. hex:sub(1, 1), 16) / 255
        g = tonumber(hex:sub(2, 2) .. hex:sub(2, 2), 16) / 255
        b = tonumber(hex:sub(3, 3) .. hex:sub(3, 3), 16) / 255
    elseif len == 6 then
        -- #RRGGBB
        r = tonumber(hex:sub(1, 2), 16) / 255
        g = tonumber(hex:sub(3, 4), 16) / 255
        b = tonumber(hex:sub(5, 6), 16) / 255
    elseif len == 8 then
        -- #RRGGBBAA
        r = tonumber(hex:sub(1, 2), 16) / 255
        g = tonumber(hex:sub(3, 4), 16) / 255
        b = tonumber(hex:sub(5, 6), 16) / 255
        a = tonumber(hex:sub(7, 8), 16) / 255
    end
    
    return Color(r, g, b, a)
end

--- 从 HSV 创建颜色
---@param h number @色相 [0-360]
---@param s number @饱和度 [0-1]
---@param v number @明度 [0-1]
---@param a number|nil @透明度 [0-1]
---@return Color
function Color.fromHSV(h, s, v, a)
    a = a or 1
    h = h % 360
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    
    local r, g, b = 0, 0, 0
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    
    return Color(r + m, g + m, b + m, a)
end

--- 从整数 RGB 创建颜色 (0-255)
---@param r integer @红色 [0-255]
---@param g integer @绿色 [0-255]
---@param b integer @蓝色 [0-255]
---@param a integer|nil @透明度 [0-255]
---@return Color
function Color.fromRGB255(r, g, b, a)
    return Color(r / 255, g / 255, b / 255, (a or 255) / 255)
end

-- ========== 预设颜色 ==========

---白色
Color.WHITE = Color(1, 1, 1, 1)
---黑色
Color.BLACK = Color(0, 0, 0, 1)
---红色
Color.RED = Color(1, 0, 0, 1)
---绿色
Color.GREEN = Color(0, 1, 0, 1)
---蓝色
Color.BLUE = Color(0, 0, 1, 1)
---黄色
Color.YELLOW = Color(1, 1, 0, 1)
---青色
Color.CYAN = Color(0, 1, 1, 1)
---品红色
Color.MAGENTA = Color(1, 0, 1, 1)
--- 灰色
Color.GRAY = Color(0.5, 0.5, 0.5, 1)
--- 透明色
Color.TRANSPARENT = Color(0, 0, 0, 0)

-- 常用 UI 颜色

--- 浅灰色
Color.LIGHT_GRAY = Color(0.8, 0.8, 0.8, 1)
--- 深灰色
Color.DARK_GRAY = Color(0.2, 0.2, 0.2, 1)
--- 橙色
Color.ORANGE = Color(1, 0.5, 0, 1)
--- 紫色
Color.PURPLE = Color(0.5, 0, 0.5, 1)
--- 粉色
Color.PINK = Color(1, 0.75, 0.8, 1)
--- 棕色
Color.BROWN = Color(0.6, 0.4, 0.2, 1)

return Color
