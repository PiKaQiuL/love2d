-- Engine/Utils.lua
-- 模块：通用工具函数
-- 功能：提供常用数学与便捷函数，减少重复代码
-- 依赖：标准 Lua；可与 Love2D 一起使用
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 全局注意：工具函数尽量纯函数，便于测试与复用。
-- 性能提示：避免在热路径（每帧循环）频繁创建临时表；按需内联。

local Utils = {}

--- 计算二维点距离
---@param x1 number 点1X
---@param y1 number 点1Y
---@param x2 number 点2X
---@param y2 number 点2Y
---@return number 欧氏距离
function Utils.calcDistance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx*dx + dy*dy)
end

--- 线性插值
---@param a number 起始值
---@param b number 结束值
---@param t number 插值系数 [0,1]
---@return number 插值结果
function Utils.lerp(a, b, t)
  return a + (b - a) * t
end

--- 限制数值范围
---@param v number 输入值
---@param min number 最小值
---@param max number 最大值
---@return number 限制后的值
-- 使用示例：
-- local hp = Utils.clamp(120, 0, 100) -- 100
function Utils.clamp(v, min, max)
  if v < min then return min end
  if v > max then return max end
  return v
end

return Utils
