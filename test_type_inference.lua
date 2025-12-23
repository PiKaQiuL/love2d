-- 测试文件：验证 UI 组件的类型推断
-- 说明：此文件用于测试 Lua Language Server 是否能正确推断 Label() 等调用的返回类型

local Label = require("Engine.UI.Label")
local Button = require("Engine.UI.Button")
local Panel = require("Engine.UI.Panel")
local TextInput = require("Engine.UI.TextInput")
local ListView = require("Engine.UI.ListView")
local ProgressBar = require("Engine.UI.ProgressBar")
local Layout = require("Engine.UI.Layout")

-- 测试 1: Label 类型推断
local label = Label()
    :setText("Hello World")
    :setColor(1, 1, 1, 1)
    :setPosition(10, 10)
    :setSize(100, 30)

-- 如果类型推断正确，以下访问应该有自动完成提示
print(label.text)   -- 应该能识别 text 字段
print(label.color)  -- 应该能识别 color 字段
print(label.font)   -- 应该能识别 font 字段

-- 测试 2: Button 类型推断
local button = Button()
    :setText("Click Me")
    :setPosition(10, 50)
    :setSize(120, 30)

-- 应该能识别 Button 特有的字段
print(button.state)     -- 应该能识别 state 字段
print(button.label)     -- 应该能识别 label 字段

-- 测试 3: Panel 类型推断
local panel = Panel()
    :setPosition(200, 100)
    :setSize(300, 200)
    :setFill({0.1, 0.1, 0.1, 1})

-- 应该能识别 Panel 特有的字段
print(panel.fill)       -- 应该能识别 fill 字段
print(panel.border)     -- 应该能识别 border 字段

-- 测试 4: 链式调用中的类型推断
-- 每一步方法调用都应该返回正确的类型，继续提供智能提示
local input = TextInput()
    :setPosition(10, 100)
    :setSize(200, 28)
    :setPlaceholder("Enter text...")  -- 应该有 setPlaceholder 提示
    :setEnabled(true)                 -- 继承自 Widget 的方法

-- 测试 5: Layout 嵌套类型推断
local layout = Layout()
    :setPosition(400, 50)
    :setSize(200, 300)
    :setDirection("vertical")
    :setSpacing(8)

layout:add(
    Label()
        :setText("Item 1")
        :setColor(1, 1, 1, 1)
)

layout:add(
    Button()
        :setText("Button in Layout")
        :setSize(180, 30)
)

-- 测试 6: ListView 类型推断
local list = ListView()
    :setPosition(50, 200)
    :setWidth(200)
    :setItemHeight(20)
    :setMaxVisible(5)

list:add("Item 1")
list:add("Item 2")

-- 应该能识别 ListView 特有的方法和字段
print(list.items)       -- 应该能识别 items 字段
print(list.selected)    -- 应该能识别 selected 字段

-- 测试 7: ProgressBar 类型推断
local progress = ProgressBar()
    :setPosition(50, 400)
    :setSize(300, 20)
    :setRange(0, 100)
    :setValue(50)

print(progress.value)   -- 应该能识别 value 字段
print(progress.min)     -- 应该能识别 min 字段
print(progress.max)     -- 应该能识别 max 字段

print("✓ 类型推断测试文件创建成功")
print("请在支持 Lua Language Server 的编辑器中打开此文件，")
print("验证代码补全和类型提示是否正常工作。")
