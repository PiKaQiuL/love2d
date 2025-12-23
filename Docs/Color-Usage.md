# Color 工具类使用文档

## 📌 概述

`Color` 是一个完整的颜色工具类，提供颜色创建、转换、运算和预设颜色功能。

## 🎨 核心功能

### 1. 多种创建方式

```lua
local Color = require("Engine.Utils.Color")

-- 方式 1: RGBA 浮点数 (0-1)
local red = Color(1, 0, 0, 1)

-- 方式 2: 从数组/表
local green = Color({0, 1, 0, 1})
local blue = Color({r=0, g=0, b=1, a=1})

-- 方式 3: 从十六进制字符串
local orange = Color("#FF8800")
local cyan = Color("#0FF")
local semiTrans = Color("#FF0000AA")

-- 方式 4: 静态工厂方法
local yellow = Color.fromRGB255(255, 255, 0)  -- 0-255 整数
local purple = Color.fromHSV(270, 1, 1)       -- 色相/饱和度/明度
local pink = Color.fromHex("#FFC0CB")
```

### 2. 颜色转换

```lua
local color = Color(0.5, 0.3, 0.8, 1)

-- 转为数组
local arr = color:toArray()  -- {0.5, 0.3, 0.8, 1}

-- 转为十六进制
local hex = color:toHex()    -- "#804DCC"
local hexAlpha = color:toHex(true)  -- "#804DCCFF"

-- 转为 HSV
local h, s, v = color:toHSV()  -- 色相, 饱和度, 明度
```

### 3. 颜色运算

```lua
-- 颜色插值（渐变）
local start = Color.RED
local end_color = Color.BLUE
local mid = start:lerp(end_color, 0.5)  -- 中间紫色

-- 调整亮度
local bright = color:brightness(1.5)  -- 变亮 50%
local dark = color:brightness(0.5)    -- 变暗 50%

-- 颜色混合
local c1 = Color(0.5, 0, 0, 1)
local c2 = Color(0, 0.5, 0, 1)
local mixed = c1:add(c2)      -- 加法混合
local mult = c1:multiply(c2)  -- 乘法混合

-- 颜色变换
local inverted = color:invert()     -- 反色
local gray = color:grayscale()      -- 灰度化
```

### 4. 链式调用

```lua
local customColor = Color()
    :set(0.8, 0.2, 0.5, nil)
    :setAlpha(0.9)
    :brightness(1.2)

local cloned = color:clone()
```

### 5. 预设颜色

```lua
Color.WHITE        -- (1, 1, 1, 1)
Color.BLACK        -- (0, 0, 0, 1)
Color.RED          -- (1, 0, 0, 1)
Color.GREEN        -- (0, 1, 0, 1)
Color.BLUE         -- (0, 0, 1, 1)
Color.YELLOW       -- (1, 1, 0, 1)
Color.CYAN         -- (0, 1, 1, 1)
Color.MAGENTA      -- (1, 0, 1, 1)
Color.GRAY         -- (0.5, 0.5, 0.5, 1)
Color.LIGHT_GRAY   -- (0.8, 0.8, 0.8, 1)
Color.DARK_GRAY    -- (0.2, 0.2, 0.2, 1)
Color.ORANGE       -- (1, 0.5, 0, 1)
Color.PURPLE       -- (0.5, 0, 0.5, 1)
Color.PINK         -- (1, 0.75, 0.8, 1)
Color.BROWN        -- (0.6, 0.4, 0.2, 1)
Color.TRANSPARENT  -- (0, 0, 0, 0)
```

## 💡 实际应用

### UI 组件中使用

```lua
local Label = require("Engine.UI.Label")
local Color = require("Engine.Utils.Color")

-- 创建带颜色的标签
local label = Label()
    :setText("Hello World")
    :setColor(Color.RED:toArray())
    
-- 或直接传递分量
local color = Color.BLUE
label:setColor(color.r, color.g, color.b, color.a)

-- 渐变效果
local startColor = Color.RED
local endColor = Color.YELLOW
local t = 0.5  -- 插值因子
local gradient = startColor:lerp(endColor, t)
label:setColor(gradient.r, gradient.g, gradient.b, gradient.a)
```

### Love2D 绘制

```lua
-- 直接应用颜色
local color = Color(0.8, 0.2, 0.5, 1)
color:apply()  -- 等价于 love.graphics.setColor(0.8, 0.2, 0.5, 1)
love.graphics.rectangle("fill", 100, 100, 50, 50)

-- 解包数组
local arr = color:toArray()
love.graphics.setColor(unpack(arr))
```

### 动态颜色效果

```lua
-- 脉动效果
local baseColor = Color(1, 0, 0, 1)
local time = 0

function update(dt)
    time = time + dt
    local factor = 0.5 + math.sin(time * 2) * 0.5
    local pulseColor = baseColor:brightness(factor)
    pulseColor:apply()
end

-- 彩虹循环
function rainbowColor(time)
    local hue = (time * 60) % 360  -- 每6秒一个循环
    return Color.fromHSV(hue, 1, 1)
end
```

## 📊 API 参考

### 构造函数

```lua
Color(r, g, b, a)           -- 浮点数 RGBA
Color({r, g, b, a})         -- 数组形式
Color({r=r, g=g, b=b, a=a}) -- 表形式
Color("#RRGGBB")            -- 十六进制字符串
```

### 实例方法

| 方法 | 返回 | 说明 |
|------|------|------|
| `toArray()` | `number[]` | 转为数组 `{r,g,b,a}` |
| `toTable()` | `number[]` | 同 `toArray()` |
| `toHex(includeAlpha?)` | `string` | 转为十六进制字符串 |
| `toHSV()` | `h, s, v` | 转为 HSV 色彩空间 |
| `clone()` | `Color` | 克隆颜色 |
| `set(r, g, b, a)` | `self` | 设置分量（链式） |
| `setAlpha(a)` | `self` | 设置透明度（链式） |
| `lerp(other, t)` | `Color` | 线性插值 |
| `add(other)` | `Color` | 加法混合 |
| `multiply(other)` | `Color` | 乘法混合 |
| `brightness(factor)` | `Color` | 调整亮度 |
| `invert()` | `Color` | 反色 |
| `grayscale()` | `Color` | 灰度化 |
| `apply()` | `void` | 应用到 love.graphics |

### 静态方法

| 方法 | 返回 | 说明 |
|------|------|------|
| `fromHex(hex)` | `Color` | 从十六进制创建 |
| `fromHSV(h, s, v, a?)` | `Color` | 从 HSV 创建 |
| `fromRGB255(r, g, b, a?)` | `Color` | 从 0-255 整数创建 |

## ⚡ 性能提示

- 预设颜色（如 `Color.RED`）是预创建的，直接使用很高效
- 避免在每帧创建新颜色对象，尽量复用或使用 `set()` 方法
- `toArray()` 和 `toTable()` 每次调用都会创建新数组
- `apply()` 方法是最快的应用颜色方式

## 🎯 最佳实践

```lua
-- ✅ 推荐：复用颜色对象
local myColor = Color.RED:clone()
function update(dt)
    myColor:set(math.random(), 0, 0, 1)
    myColor:apply()
end

-- ❌ 避免：每帧创建新对象
function update(dt)
    local color = Color(math.random(), 0, 0, 1)
    color:apply()
end

-- ✅ 推荐：使用预设颜色
label:setColor(Color.WHITE:toArray())

-- ✅ 推荐：缓存转换结果
local redArray = Color.RED:toArray()
function draw()
    love.graphics.setColor(unpack(redArray))
end
```

## 📝 类型注解

所有方法都有完整的 LuaLS 类型注解，支持智能提示和类型检查。

```lua
---@type Color
local color = Color(1, 0, 0, 1)

-- 自动补全和类型检查
color:brightness(1.5)  -- ✓ 正确
color:brightness("1.5") -- ✗ 类型错误
```
