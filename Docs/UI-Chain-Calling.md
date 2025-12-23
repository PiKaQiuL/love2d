# UI组件链式调用指南

本文档说明如何使用链式调用API来创建和配置UI组件，让代码更简洁、可读性更强。

## 重要更新（2025-12-23）

**所有UI组件的init函数现在都不接受参数，必须使用链式调用来初始化所有属性！**

这一改变使得API更加统一和优雅，所有组件的创建方式完全一致。

## 基本概念

所有UI组件现在使用无参数构造函数，然后通过链式调用设置属性：

```lua
-- 新的标准写法（必须）
local button = Button()
    :setText("Click")
    :setPosition(10, 10)
    :setSize(120, 30)
    :setColors({ ... })
    :setBorderWidth(2)
    :setOnClick(function(btn) print("clicked") end)

-- 旧写法已不再支持
-- local button = Button("Click", 10, 10, 120, 30) -- ❌ 错误！
```

## 组件示例

### Button（按钮）

```lua
-- 基础用法
local btn = Button()
    :setText("Submit")
    :setPosition(100, 50)
    :setSize(140, 32)
    :setOnClick(function(self) print("Button clicked!") end)
    :setFocus(true)

-- 自定义样式
local dangerBtn = Button()
    :setText("Delete")
    :setPosition(100, 100)
    :setSize(140, 32)
    :setColors({
        normal = { 0.8, 0.2, 0.2, 1 },
        hover = { 0.9, 0.3, 0.3, 1 },
        pressed = { 0.7, 0.1, 0.1, 1 },
        border = { 1, 0.6, 0.6, 1 },
        text = { 1, 1, 1, 1 }
    })
    :setBorderWidth(2)
    :setOnClick(onDeleteClicked)

-- 禁用按钮
local disabledBtn = Button()
    :setText("Disabled")
    :setPosition(100, 150)
    :setSize(140, 32)
    :setDisabled(true)
```

### Panel（面板）

```lua
-- 基础面板
local panel = Panel()
    :setPosition(10, 10)
    :setSize(300, 200)
    :setFill({ 0.1, 0.1, 0.12, 0.95 })
    :setBorder({ 1, 1, 1, 0.8 })
    :setBorderWidth(2)
    :setPadding(8)

-- 中心锚点面板（配合 Vector2）
local centerPanel = Panel()
    :setSize(120, 80)
    :setPivotCenter()
    :setPositionV(Vector2(400, 300))
    :setFill({ 0.2, 0.3, 0.4, 0.9 })
```

### Label（标签）

```lua
-- 基础标签
local label = Label()
    :setText("Hello World")
    :setPosition(10, 10)
    :setColor(1, 1, 1, 1)

-- 彩色标签
local titleLabel = Label()
    :setText("Title")
    :setPosition(100, 50)
    :setColor(1, 1, 0.6, 1)
    :setFont(customFont)
```

### TextInput（输入框）

```lua
-- 基础输入框
local input = TextInput()
    :setPosition(10, 10)
    :setSize(200, 28)
    :setPlaceholder("Enter your name...")

-- 自定义样式
local styledInput = TextInput()
    :setPosition(10, 50)
    :setSize(220, 32)
    :setPlaceholder("Email address")
    :setColors({
        bg = { 0.05, 0.05, 0.08, 1 },
        border = { 0.6, 0.8, 1.0, 0.9 },
        text = { 1, 1, 1, 1 },
        placeholder = { 0.5, 0.5, 0.5, 0.7 }
    })
```

### ListView（列表视图）

```lua
-- 基础列表
local list = ListView()
    :setPosition(10, 10)
    :setWidth(200)
    :setItemHeight(18)
    :setMaxVisible(6)
    :setColors({
        bg = { 0.05, 0.05, 0.08, 1 },
        border = { 0.8, 0.8, 1.0, 0.9 },
        text = { 1, 1, 1, 1 },
        hover = { 0.2, 0.25, 0.3, 0.8 },
        selected = { 0.3, 0.5, 0.3, 0.8 }
    })
    :setOnSelect(function(self, index, value)
        print("Selected:", index, value)
    end)

-- 添加项目
for i = 1, 30 do
    list:add("Item " .. i)
end
```

### ProgressBar（进度条）

```lua
-- 基础进度条
local progress = ProgressBar()
    :setPosition(10, 10)
    :setSize(200, 16)
    :setRange(0, 100)
    :setValue(50)

-- 自定义样式
local hpBar = ProgressBar()
    :setPosition(10, 50)
    :setSize(160, 12)
    :setRange(0, 100)
    :setValue(75)
    :setColors({
        bg = { 0.1, 0.1, 0.1, 1 },
        fill = { 0.2, 0.8, 0.2, 0.9 },
        border = { 0.5, 1, 0.5, 0.8 }
    })
    :setBorderWidth(1)
```

### Layout（布局容器）

```lua
-- 垂直布局
local vLayout = Layout()
    :setPosition(10, 10)
    :setSize(300, 400)
    :setDirection(Enums.LayoutDirection.vertical)
    :setSpacing(8)
    :setPadding(10)
    :setAlign(Enums.Align.center)

-- 添加子组件
vLayout:add(Label():setText("Title"):setColor(1, 1, 0.6, 1))
vLayout:add(Button():setText("Action 1"):setSize(140, 32):setOnClick(onClick1))
vLayout:add(Button():setText("Action 2"):setSize(140, 32):setOnClick(onClick2))

-- 水平布局
local hLayout = Layout()
    :setPosition(10, 10)
    :setSize(400, 100)
    :setDirection(Enums.LayoutDirection.horizontal)
    :setSpacing(12)
    :setPadding({ l = 10, t = 10, r = 10, b = 10 })
```

## 完整示例

### 创建登录表单

```lua
local loginForm = Layout()
    :setPosition(100, 100)
    :setSize(300, 200)
    :setDirection(Enums.LayoutDirection.vertical)
    :setSpacing(12)
    :setPadding(20)
    :setAlign(Enums.Align.center)

local title = Label()
    :setText("Login")
    :setColor(1, 1, 0.8, 1)

local usernameInput = TextInput()
    :setSize(260, 32)
    :setPlaceholder("Username")

local passwordInput = TextInput()
    :setSize(260, 32)
    :setPlaceholder("Password")

local submitBtn = Button()
    :setText("Login")
    :setSize(140, 36)
    :setOnClick(function(btn)
        handleLogin(usernameInput:getText(), passwordInput:getText())
    end)

loginForm:add(title)
loginForm:add(usernameInput)
loginForm:add(passwordInput)
loginForm:add(submitBtn)
```

## 优势

1. **API统一**：所有组件使用相同的创建模式
2. **代码更简洁**：配置集中，意图清晰
3. **可读性强**：每个属性的设置一目了然
4. **灵活组合**：可以根据条件动态添加配置
5. **减少错误**：避免参数顺序错误

## 迁移指南

### 旧写法（已废弃）
```lua
local button = Button("Click", 10, 10, 120, 30)
local panel = Panel(10, 10, 300, 200)
local label = Label("Hello", 10, 10)
```

### 新写法（必须使用）
```lua
local button = Button()
    :setText("Click")
    :setPosition(10, 10)
    :setSize(120, 30)

local panel = Panel()
    :setPosition(10, 10)
    :setSize(300, 200)

local label = Label()
    :setText("Hello")
    :setPosition(10, 10)
```

**所有现有代码都必须迁移到新的无参数构造函数 + 链式调用模式！**
