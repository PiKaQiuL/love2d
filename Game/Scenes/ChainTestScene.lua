-- Game/Scenes/ChainTestScene.lua
-- 链式调用测试场景：展示所有UI组件的链式调用用法

local Scene = require("Engine.Core.Scene")
local Layout = require("Engine.UI.Layout")
local Button = require("Engine.UI.Button")
local Panel = require("Engine.UI.Panel")
local Label = require("Engine.UI.Label")
local TextInput = require("Engine.UI.TextInput")
local ListView = require("Engine.UI.ListView")
local ProgressBar = require("Engine.UI.ProgressBar")
local Enums = require("Engine.Core.Enums")
local Vector2 = require("Engine.Utils.Vector2")
local Color = require("Engine.Utils.Color")

local ChainTestScene = Scene:extend()

function ChainTestScene:enter()
    if self.app and self.app.logger then
        self.app.logger:info("ChainTest scene enter")
    end

    -- 标题
    self.title = Label()
        :setText("UI Chain Calling Test Scene")
        :setPosition(20, 10)
        :setColor(1, 1, 0.6, 1)

    -- 按钮组
    self.buttonLayout = Layout()
        :setPosition(20, 40)
        :setSize(300, 200)
        :setDirection(Enums.LayoutDirection.vertical)
        :setSpacing(8)
        :setPadding(10)
        :setAlign(Enums.Align.start)

    local btn1 = Button()
        :setText("Normal Button")
        :setSize(160, 32)
        :setOnClick(function(btn)
            print("Button 1 clicked!")
        end)

    local btn2 = Button()
        :setText("Disabled Button")
        :setSize(160, 32)
        :setDisabled(true)
        :setOnClick(function(btn)
            print("This should not print")
        end)

    local btn3 = Button()
        :setText("Danger Button")
        :setSize(160, 32)
        :setColors({
            normal = { 0.8, 0.2, 0.2, 1 },
            hover = { 0.9, 0.3, 0.3, 1 },
            pressed = { 0.7, 0.1, 0.1, 1 },
            border = { 1, 0.6, 0.6, 1 },
            text = { 1, 1, 1, 1 },
            disabled = { 0.4, 0.4, 0.4, 1 },
            focus = { 1, 0.4, 0.4, 1 }
        })
        :setBorderWidth(2)
        :setOnClick(function(btn)
            print("Danger button clicked!")
        end)

    self.buttonLayout:add(btn1)
    self.buttonLayout:add(btn2)
    self.buttonLayout:add(btn3)

    -- 面板示例
    self.panel = Panel()
        :setPosition(340, 40)
        :setSize(260, 120)
        :setFill(Color { 0.1, 0.1, 0.15, 0.95 })
        :setBorder(Color { 0.8, 0.9, 1.0, 0.8 })
        :setBorderWidth(2)
        :setPadding(8)

    local panelLabel = Label()
        :setText("This is a Panel")
        :setPosition(10, 10)
        :setColor(0.9, 0.95, 1.0, 1)
    self.panel:add(panelLabel)

    -- 输入框示例
    self.input = TextInput()
        :setPosition(340, 180)
        :setSize(260, 32)
        :setPlaceholder("Enter text here...")
        :setColors({
            bg = Color { 0.05, 0.05, 0.1, 1 },
            border = Color { 0.6, 0.8, 1.0, 0.9 },
            text = Color { 1, 1, 1, 1 },
            placeholder = Color { 0.5, 0.5, 0.6, 0.8 }
        })

    -- 列表视图示例
    self.list = ListView()
        :setPosition(20, 260)
        :setWidth(200)
        :setItemHeight(20)
        :setMaxVisible(8)
        :setColors({
            bg = { 0.05, 0.05, 0.08, 1 },
            border = { 0.7, 0.8, 0.9, 0.9 },
            text = { 1, 1, 1, 1 },
            hover = { 0.2, 0.25, 0.3, 0.9 },
            selected = { 0.3, 0.5, 0.3, 0.9 }
        })
        :setOnSelect(function(self, index, value)
            print("Selected:", index, value)
        end)

    for i = 1, 20 do
        self.list:add("List Item " .. i)
    end

    -- 进度条示例
    self.progress1 = ProgressBar()
        :setPosition(340, 230)
        :setSize(260, 16)
        :setRange(0, 100)
        :setValue(35)
        :setColors({
            bg = { 0.1, 0.1, 0.1, 1 },
            fill = { 0.3, 0.7, 1.0, 0.9 },
            border = { 0.6, 0.8, 1.0, 0.8 }
        })
        :setBorderWidth(1)

    self.progress2 = ProgressBar()
        :setPosition(340, 260)
        :setSize(260, 16)
        :setRange(0, 100)
        :setValue(75)
        :setColors({
            bg = { 0.1, 0.1, 0.1, 1 },
            fill = { 0.2, 0.9, 0.3, 0.9 },
            border = { 0.5, 1.0, 0.6, 0.8 }
        })

    -- 提示
    self.hint = Label()
        :setText("[F1] Back to Main | [Space] Update Progress")
        :setPosition(20, 450)
        :setColor(0.7, 0.8, 0.9, 1)

    -- 更新进度条的计时器
    self.progressValue = 0
    self.app.timer:every(0.1, function()
        self.progressValue = (self.progressValue + 2) % 100
        self.progress1:setValue(self.progressValue)
        self.progress2:setValue((self.progressValue + 50) % 100)
    end)
end

function ChainTestScene:keypressed(key)
    if key == "f1" then
        if self.app then
            self.app:switchScene("main")
        end
        return
    end
    if key == "space" then
        -- 手动更新进度
        local v1 = (self.progress1:getValue() + 10) % 100
        local v2 = (self.progress2:getValue() + 15) % 100
        self.progress1:setValue(v1)
        self.progress2:setValue(v2)
        print("Progress updated:", v1, v2)
    end
end

function ChainTestScene:mousepressed(x, y, button)
    -- 转发输入事件到列表
    if self.list and self.list.hitTest and self.list:hitTest(x, y) then
        if self.list.mousepressed then
            self.list:mousepressed(x, y, button)
        end
    end
    -- 转发到输入框
    if self.input and self.input.mousepressed then
        self.input:mousepressed(x, y, button)
    end
end

function ChainTestScene:mousemoved(x, y, dx, dy)
    if self.list and self.list.mousemoved then
        self.list:mousemoved(x, y)
    end
end

function ChainTestScene:mousereleased(x, y, button)
    if self.list and self.list.mousereleased then
        self.list:mousereleased(x, y, button)
    end
end

function ChainTestScene:wheelmoved(dx, dy)
    if self.list then
        local mx, my = love.mouse.getPosition()
        if self.list.hitTest and self.list:hitTest(mx, my) then
            if self.list.wheelmoved then
                self.list:wheelmoved(dx, dy)
            end
        end
    end
end

function ChainTestScene:textinput(text)
    if self.input and self.input.textinput then
        self.input:textinput(text)
    end
end

function ChainTestScene:draw()
    love.graphics.setColor(1, 1, 1, 1)

    -- 绘制所有组件
    if self.title then self.title:draw() end
    if self.buttonLayout then self.buttonLayout:draw() end
    if self.panel then self.panel:draw() end
    if self.input then self.input:draw() end
    if self.list then self.list:draw() end
    if self.progress1 then self.progress1:draw() end
    if self.progress2 then self.progress2:draw() end
    if self.hint then self.hint:draw() end

    -- 显示输入框的当前文本
    if self.input then
        love.graphics.setColor(0.8, 0.9, 1, 1)
        love.graphics.print("Input: " .. self.input:getText(), 340, 220)
    end
end

function ChainTestScene:leave()
    if self.app and self.app.logger then
        self.app.logger:info("ChainTest scene leave")
    end
end

return ChainTestScene
