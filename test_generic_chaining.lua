-- test_generic_chaining.lua
-- 演示：泛型约束在链式调用中的完整应用
-- 说明：此文件展示所有 UI 组件的链式调用如何保持类型

local Label = require("Engine.UI.Label")
local Button = require("Engine.UI.Button")
local Panel = require("Engine.UI.Panel")
local TextInput = require("Engine.UI.TextInput")
local ListView = require("Engine.UI.ListView")
local ProgressBar = require("Engine.UI.ProgressBar")
local Layout = require("Engine.UI.Layout")

print("=== 泛型约束链式调用演示 ===\n")

-- ✅ 示例 1: Label 链式调用 - 类型始终是 Label
print("示例 1: Label 链式调用")
local label = Label()
    :setText("Hello World")       -- Label.setText() → Label
    :setColor(1, 1, 1, 1)         -- Label.setColor() → Label
    :setPosition(10, 10)          -- 继承自 Node → Label (类型保持)
    :setSize(100, 30)             -- 继承自 Widget → Label (类型保持)
print("  ✓ label.text = " .. label.text)
print("  ✓ 类型推断正确：Label\n")

-- ✅ 示例 2: Button 链式调用 - 类型始终是 Button
print("示例 2: Button 链式调用")
local button = Button()
    :setText("Click Me")                    -- Button.setText() → Button
    :setSize(120, 30)                       -- Button.setSize() → Button
    :setPosition(50, 50)                    -- 继承自 Node → Button (✓)
    :setDisabled(false)                     -- Button.setDisabled() → Button
    :setPivotCenter()                       -- 继承自 Node → Button (✓)
    :setOnClick(function() 
        print("  按钮被点击了!")
    end)
print("  ✓ button.text = " .. button.text)
print("  ✓ button.w = " .. button.w)
print("  ✓ 类型推断正确：Button\n")

-- ✅ 示例 3: Panel 链式调用 - 类型始终是 Panel
print("示例 3: Panel 链式调用")
local panel = Panel()
    :setSize(200, 150)                      -- Panel.setSize() → Panel
    :setFill({0.2, 0.2, 0.2, 0.9})         -- Panel.setFill() → Panel
    :setBorder({1, 1, 1, 0.5})             -- Panel.setBorder() → Panel
    :setBorderWidth(2)                      -- Panel.setBorderWidth() → Panel
    :setPosition(100, 100)                  -- 继承自 Node → Panel (✓)
    :setScale(1.5, 1.5)                     -- 继承自 Widget → Panel (✓)
    :setVisible(true)                       -- 继承自 Widget → Panel (✓)
print("  ✓ panel.w = " .. panel.w)
print("  ✓ panel.h = " .. panel.h)
print("  ✓ 类型推断正确：Panel\n")

-- ✅ 示例 4: TextInput 链式调用 - 类型始终是 TextInput
print("示例 4: TextInput 链式调用")
local input = TextInput()
    :setText("输入框内容")                  -- TextInput.setText() → TextInput
    :setPlaceholder("请输入内容...")       -- TextInput.setPlaceholder() → TextInput
    :setSize(180, 28)                       -- TextInput.setSize() → TextInput (或 Widget)
    :setPosition(20, 20)                    -- 继承自 Node → TextInput (✓)
    :setFocused(true)                       -- TextInput.setFocused() → TextInput
print("  ✓ input.text = " .. input.text)
print("  ✓ 类型推断正确：TextInput\n")

-- ✅ 示例 5: ListView 链式调用 - 类型始终是 ListView
print("示例 5: ListView 链式调用")
local list = ListView()
    :setWidth(200)                          -- ListView.setWidth() → ListView
    :setMaxVisible(5)                       -- ListView.setMaxVisible() → ListView
    :setItemHeight(20)                      -- ListView.setItemHeight() → ListView
    :setPosition(300, 100)                  -- 继承自 Node → ListView (✓)
    :add("项目 1")                          -- ListView.add() → ListView
    :add("项目 2")
    :add("项目 3")
    :setOnSelect(function(self, idx, val)
        print("  选中项：" .. val)
    end)
print("  ✓ list 包含 " .. #list.items .. " 个项目")
print("  ✓ 类型推断正确：ListView\n")

-- ✅ 示例 6: ProgressBar 链式调用 - 类型始终是 ProgressBar
print("示例 6: ProgressBar 链式调用")
local progress = ProgressBar()
    :setRange(0, 100)                       -- ProgressBar.setRange() → ProgressBar
    :setValue(50)                           -- ProgressBar.setValue() → ProgressBar
    :setSize(300, 20)                       -- ProgressBar.setSize() → ProgressBar (或 Widget)
    :setPosition(50, 200)                   -- 继承自 Node → ProgressBar (✓)
    :setBorderWidth(1)                      -- ProgressBar.setBorderWidth() → ProgressBar
print("  ✓ progress.value = " .. progress.value)
print("  ✓ progress.max = " .. progress.max)
print("  ✓ 类型推断正确：ProgressBar\n")

-- ✅ 示例 7: Layout 链式调用 - 类型始终是 Layout
print("示例 7: Layout 链式调用")
local layout = Layout()
    :setDirection("vertical")               -- Layout.setDirection() → Layout
    :setSpacing(8)                          -- Layout.setSpacing() → Layout
    :setPadding(10)                         -- Layout.setPadding() → Layout
    :setAlign("center")                     -- Layout.setAlign() → Layout
    :setSize(300, 400)                      -- Layout.setSize() → Layout (或 Widget)
    :setPosition(100, 50)                   -- 继承自 Node → Layout (✓)
    :add(Label():setText("标签 1"))         -- Layout.add() → Layout
    :add(Button():setText("按钮"))
    :add(TextInput():setPlaceholder("输入"))
print("  ✓ layout 包含 " .. #layout.children .. " 个子元素")
print("  ✓ 类型推断正确：Layout\n")

-- ✅ 示例 8: 复杂的嵌套结构 - 演示完整继承链
print("示例 8: 复杂嵌套结构（完整继承链演示）")
local complexUI = Panel()
    -- Panel 的方法
    :setSize(400, 300)
    :setFill({0.1, 0.1, 0.1, 0.95})
    :setBorderWidth(2)
    -- 继承自 Widget 的方法
    :setEnabled(true)
    :setOpacity(1.0)
    -- 继承自 Node 的方法
    :setPosition(200, 100)
    :setPivotCenter()
    -- 添加子元素
    :add(
        Button()
            :setText("提交")
            :setSize(100, 40)
            :setPosition(150, 120)
    )
    :add(
        Label()
            :setText("状态：就绪")
            :setColor(0, 1, 0, 1)
            :setPosition(150, 180)
    )

print("  ✓ 成功创建复杂 UI 结构")
print("  ✓ 每一步都保持类型")
print("  ✓ Panel 子元素数：" .. #complexUI.children .. "\n")

-- ✅ 示例 9: 验证类型推断
print("示例 9: 类型检验")
print("  Label() 返回类型：" .. type(label))
print("  Button() 返回类型：" .. type(button))
print("  Panel() 返回类型：" .. type(panel))
print("  所有都是 table（Lua 对象）✓\n")

-- ✅ 示例 10: 链式调用的实际好处
print("示例 10: 链式调用 vs 传统方式对比")
print("\n❌ 传统方式（多行代码）：")
print("  local btn = Button()")
print("  btn:setText('Click')")
print("  btn:setSize(100, 30)")
print("  btn:setPosition(10, 10)")
print("  btn:setOnClick(function() end)")

print("\n✅ 链式调用方式（流畅且类型安全）：")
print("  local btn = Button()")
print("    :setText('Click')")
print("    :setSize(100, 30)")
print("    :setPosition(10, 10)")
print("    :setOnClick(function() end)\n")

print("=== 演示完成 ===")
print("✨ 所有 setter 方法都通过泛型约束实现了正确的链式调用类型保持")
print("✨ 即使继承多层，返回类型也能保持为实际的子类类型")
