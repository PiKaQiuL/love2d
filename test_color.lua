-- test_color.lua
-- 颜色工具类测试文件

local Color = require("Engine.Utils.Color")

print("=== Color 工具类测试 ===\n")

-- 测试 1: 基本创建
print("测试 1: 基本颜色创建")
local c1 = Color(1, 0, 0, 1)
print("  红色:", c1)
print("  数组形式:", table.concat(c1:toArray(), ", "))
print("  十六进制:", c1:toHex())

-- 测试 2: 从表创建
print("\n测试 2: 从表创建")
local c2 = Color({0.5, 0.5, 0.5, 1})
print("  灰色:", c2)
print("  十六进制:", c2:toHex())

-- 测试 3: 从十六进制创建
print("\n测试 3: 从十六进制创建")
local c3 = Color("#FF5733")
print("  #FF5733 =", c3)
local c4 = Color("#F00")
print("  #F00 =", c4)
local c5 = Color("#FF0000AA")
print("  #FF0000AA =", c5)

-- 测试 4: 静态方法
print("\n测试 4: 静态方法")
local c6 = Color.fromHex("#00FF00")
print("  fromHex(#00FF00):", c6)
local c7 = Color.fromRGB255(255, 128, 0)
print("  fromRGB255(255, 128, 0):", c7)
local c8 = Color.fromHSV(120, 1, 1)
print("  fromHSV(120, 1, 1):", c8)

-- 测试 5: HSV 转换
print("\n测试 5: HSV 转换")
local red = Color(1, 0, 0, 1)
local h, s, v = red:toHSV()
print("  红色的 HSV:", string.format("H=%.1f, S=%.2f, V=%.2f", h, s, v))

-- 测试 6: 颜色运算
print("\n测试 6: 颜色运算")
local c9 = Color(0.5, 0.5, 0.5, 1)
local c10 = c9:brightness(2)
print("  原色:", c9)
print("  亮度 x2:", c10)
local c11 = c9:invert()
print("  反色:", c11)
local c12 = c9:grayscale()
print("  灰度:", c12)

-- 测试 7: 颜色插值
print("\n测试 7: 颜色插值")
local red2 = Color(1, 0, 0, 1)
local blue = Color(0, 0, 1, 1)
local purple = red2:lerp(blue, 0.5)
print("  红色:", red2)
print("  蓝色:", blue)
print("  插值(0.5):", purple)

-- 测试 8: 颜色混合
print("\n测试 8: 颜色混合")
local c13 = Color(0.5, 0, 0, 1)
local c14 = Color(0, 0.5, 0, 1)
local c15 = c13:add(c14)
print("  颜色1:", c13)
print("  颜色2:", c14)
print("  加法混合:", c15)
local c16 = c13:multiply(Color(2, 1, 1, 1))
print("  乘法混合:", c16)

-- 测试 9: 预设颜色
print("\n测试 9: 预设颜色")
print("  WHITE:", Color.WHITE)
print("  BLACK:", Color.BLACK)
print("  RED:", Color.RED)
print("  GREEN:", Color.GREEN)
print("  BLUE:", Color.BLUE)
print("  YELLOW:", Color.YELLOW)
print("  CYAN:", Color.CYAN)
print("  MAGENTA:", Color.MAGENTA)
print("  GRAY:", Color.GRAY)
print("  LIGHT_GRAY:", Color.LIGHT_GRAY)
print("  DARK_GRAY:", Color.DARK_GRAY)
print("  ORANGE:", Color.ORANGE)
print("  PURPLE:", Color.PURPLE)

-- 测试 10: 链式调用
print("\n测试 10: 链式调用")
local c17 = Color(0.3, 0.3, 0.3, 0.5)
    :set(0.5, 0.5, 0.5, nil)
    :setAlpha(1.0)
print("  链式设置:", c17)

-- 测试 11: 克隆
print("\n测试 11: 克隆")
local c18 = Color(1, 0, 0, 1)
local c19 = c18:clone()
c19:set(0, 1, 0, nil)
print("  原色:", c18)
print("  克隆后修改:", c19)

print("\n=== 测试完成 ===")
