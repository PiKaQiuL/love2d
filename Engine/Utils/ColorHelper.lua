-- Engine/Utils/ColorHelper.lua
-- 颜色辅助函数：UI 组件使用的颜色工具
-- 模块：颜色辅助
-- 功能：统一处理颜色参数（Color 对象、数组、分量）
-- 依赖：Engine.Utils.Color
-- 作者：Team
-- 修改时间：2025-12-23

local Color = require("Engine.Utils.Color")

local ColorHelper = {}

--- 规范化颜色参数为数组 {r, g, b, a}
---@param r number|table|Color|nil @红色分量、颜色对象或颜色数组
---@param g number|nil @绿色分量
---@param b number|nil @蓝色分量
---@param a number|nil @透明度
---@return number[] @颜色数组 {r, g, b, a}
function ColorHelper.normalize(r, g, b, a)
    -- 如果是 Color 对象
    if type(r) == "table" and r.toArray then
        return r:toArray()
    end
    
    -- 如果是数组
    if type(r) == "table" then
        return {
            r.r or r[1] or 1,
            r.g or r[2] or 1,
            r.b or r[3] or 1,
            r.a or r[4] or 1
        }
    end
    
    -- 如果是分量
    return { r or 1, g or 1, b or 1, a or 1 }
end

--- 应用颜色到 love.graphics
---@param r number|table|Color|nil @红色分量、颜色对象或颜色数组
---@param g number|nil @绿色分量
---@param b number|nil @蓝色分量
---@param a number|nil @透明度
function ColorHelper.apply(r, g, b, a)
    local color = ColorHelper.normalize(r, g, b, a)
    love.graphics.setColor(color[1], color[2], color[3], color[4])
end

--- 从任意格式创建 Color 对象
---@param r number|table|Color|string|nil @颜色参数
---@param g number|nil
---@param b number|nil
---@param a number|nil
---@return Color
function ColorHelper.toColor(r, g, b, a)
    -- 如果已经是 Color 对象
    if type(r) == "table" and r.toArray then
        return r
    end
    
    -- 其他情况用 Color 构造函数处理
    return Color(r, g, b, a)
end

--- 检查是否为有效颜色
---@param color any
---@return boolean
function ColorHelper.isColor(color)
    if type(color) ~= "table" then return false end
    
    -- 检查是否为 Color 对象
    if color.toArray then return true end
    
    -- 检查是否为颜色数组
    if #color >= 3 then
        for i = 1, math.min(#color, 4) do
            if type(color[i]) ~= "number" then return false end
        end
        return true
    end
    
    -- 检查是否为颜色表
    return type(color.r) == "number" and 
           type(color.g) == "number" and 
           type(color.b) == "number"
end

--- 颜色插值辅助（支持任意格式）
---@param color1 any @起始颜色
---@param color2 any @结束颜色
---@param t number @插值因子 [0-1]
---@return number[] @插值后的颜色数组
function ColorHelper.lerp(color1, color2, t)
    local c1 = ColorHelper.normalize(color1)
    local c2 = ColorHelper.normalize(color2)
    return {
        c1[1] + (c2[1] - c1[1]) * t,
        c1[2] + (c2[2] - c1[2]) * t,
        c1[3] + (c2[3] - c1[3]) * t,
        c1[4] + (c2[4] - c1[4]) * t
    }
end

return ColorHelper
