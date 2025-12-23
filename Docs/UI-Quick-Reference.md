# UI组件链式调用快速参考

## Button（按钮）
```lua
Button(text, x, y, w, h)
  :setText(text)           -- 设置文本
  :setSize(w, h)           -- 设置尺寸
  :setColors(colors)       -- 设置颜色集
  :setBorderWidth(width)   -- 设置边框宽度
  :setOnClick(callback)    -- 设置点击回调
  :setDisabled(bool)       -- 设置禁用状态
  :setFocus(bool)          -- 设置聚焦状态
```

## Panel（面板）
```lua
Panel(x, y, w, h)
  :setSize(w, h)           -- 设置尺寸
  :setFill(color)          -- 设置填充色
  :setBorder(color)        -- 设置边框色
  :setBorderWidth(width)   -- 设置边框宽度
  :setPadding(padding)     -- 设置内边距
```

## Label（标签）
```lua
Label(text, x, y)
  :setText(text)           -- 设置文本
  :setColor(r, g, b, a)    -- 设置颜色
  :setFont(font)           -- 设置字体
```

## TextInput（输入框）
```lua
TextInput(x, y, w, h)
  :setText(text)           -- 设置文本
  :setPlaceholder(text)    -- 设置占位符
  :setColors(colors)       -- 设置颜色集
  :setSize(w, h)           -- 设置尺寸
  :setFocused(bool)        -- 设置聚焦状态
```

## ListView（列表）
```lua
ListView(x, y, w, itemH, opts)
  :add(item)               -- 添加项目
  :clear()                 -- 清空列表
  :setOnSelect(callback)   -- 设置选中回调
  :setColors(colors)       -- 设置颜色集
  :setMaxVisible(num)      -- 设置最大可见项
  :setItemHeight(height)   -- 设置项高度
  :setWidth(width)         -- 设置宽度
  :setScroll(y)            -- 设置滚动位置
  :scrollBy(dy)            -- 相对滚动
```

## ProgressBar（进度条）
```lua
ProgressBar(x, y, w, h)
  :setRange(min, max)      -- 设置范围
  :setValue(value)         -- 设置当前值
  :setColors(colors)       -- 设置颜色集
  :setSize(w, h)           -- 设置尺寸
  :setBorderWidth(width)   -- 设置边框宽度
```

## Layout（布局）
```lua
Layout(x, y, w, h, opts)
  :setDirection(dir)       -- 设置方向
  :setSpacing(spacing)     -- 设置间距
  :setPadding(padding)     -- 设置内边距
  :setAlign(align)         -- 设置对齐
  :setJustify(justify)     -- 设置分布
  :setWrap(bool)           -- 设置换行
  :setClip(bool)           -- 设置剪裁
  :setGaps(gx, gy)         -- 设置双轴间距
  :setAutoSize(bool)       -- 设置自动尺寸
  :setSize(w, h)           -- 设置尺寸
  :add(child, opts)        -- 添加子节点
  :remove(child)           -- 移除子节点
```

## Widget（通用）
所有组件继承自Widget,共享以下方法:
```lua
widget
  :setPosition(x, y)       -- 设置位置
  :setPositionV(vec2)      -- 使用向量设置位置
  :setSize(w, h)           -- 设置尺寸
  :setSizeV(vec2)          -- 使用向量设置尺寸
  :setScale(sx, sy)        -- 设置缩放
  :setVisible(bool)        -- 设置可见性
  :setEnabled(bool)        -- 设置启用状态
  :setPivot(px, py)        -- 设置锚点
  :setPivotCenter()        -- 设置中心锚点
```

## 颜色集示例

### Button颜色集
```lua
{
  normal = {r, g, b, a},     -- 普通状态
  hover = {r, g, b, a},      -- 悬停状态
  pressed = {r, g, b, a},    -- 按下状态
  disabled = {r, g, b, a},   -- 禁用状态
  border = {r, g, b, a},     -- 边框颜色
  text = {r, g, b, a},       -- 文本颜色
  focus = {r, g, b, a}       -- 聚焦状态
}
```

### TextInput颜色集
```lua
{
  bg = {r, g, b, a},         -- 背景色
  border = {r, g, b, a},     -- 边框色
  text = {r, g, b, a},       -- 文本色
  placeholder = {r, g, b, a} -- 占位符颜色
}
```

### ListView颜色集
```lua
{
  bg = {r, g, b, a},         -- 背景色
  border = {r, g, b, a},     -- 边框色
  text = {r, g, b, a},       -- 文本色
  hover = {r, g, b, a},      -- 悬停色
  selected = {r, g, b, a}    -- 选中色
}
```

### ProgressBar颜色集
```lua
{
  bg = {r, g, b, a},         -- 背景色
  fill = {r, g, b, a},       -- 填充色
  border = {r, g, b, a}      -- 边框色
}
```

## 完整示例

```lua
-- 创建登录表单
local loginForm = Layout(100, 100, 300, 200, {
    direction = Enums.LayoutDirection.vertical,
    spacing = 12,
    padding = 20
})

local title = Label("Login", 0, 0)
    :setColor(1, 1, 0.8, 1)

local usernameInput = TextInput(0, 0, 260, 32)
    :setPlaceholder("Username")

local passwordInput = TextInput(0, 0, 260, 32)
    :setPlaceholder("Password")

local submitBtn = Button("Login", 0, 0, 140, 36)
    :setOnClick(function(btn)
        handleLogin(
            usernameInput:getText(),
            passwordInput:getText()
        )
    end)

loginForm:add(title)
loginForm:add(usernameInput)
loginForm:add(passwordInput)
loginForm:add(submitBtn)
```
