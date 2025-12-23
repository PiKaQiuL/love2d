-- Game/Scenes/ButtonTestScene.lua
-- 按钮测试场景：展示 Button 的基本交互与样式应用

local Scene = require("Engine.Core.Scene")
local Layout = require("Engine.UI.Layout")
local Button = require("Engine.UI.Button")
local Enums = require("Engine.Core.Enums")
local TextPanel = require("Game.UI.TextPanel")

local ButtonTestScene = Scene:extend()

function ButtonTestScene:enter()
    -- 日志输出
    self.log = TextPanel(40, 300, 520, { maxLines = 10 })
    self.log:add("F1 返回主场景，点击或按回车/空格触发按钮")

    -- 根布局容器
    self.root = Layout()
        :setPosition(40, 40)
        :setSize(360, 240)
        :setDirection(Enums.LayoutDirection.vertical)
        :setSpacing(8)
        :setPadding({ l = 10, t = 10, r = 10, b = 10 })

    -- 设置背景和边框（需要单独设置）
    self.root.bg = { 0.08, 0.08, 0.08, 1 }
    self.root.border = { 1, 1, 1, 0.3 }
    self.root.borderWidth = 1

    self.buttons = {}

    local function onClick(btn)
        self.log:add("[click] " .. btn.text)
    end

    -- 使用链式调用创建和配置按钮
    local b1 = Button()
        :setText("Click Me")
        :setSize(140, 32)
        :setOnClick(onClick)
    
    local b2 = Button()
        :setText("Disabled")
        :setSize(140, 32)
        :setOnClick(onClick)
        :setDisabled(true)
    
    local b3 = Button()
        :setText("Focused")
        :setSize(140, 32)
        :setOnClick(onClick)
        :setFocus(true)
    
    local b4 = Button()
        :setText("Wide Button")
        :setSize(220, 32)
        :setOnClick(onClick)
    
    local b5 = Button()
        :setText("Danger")
        :setSize(140, 32)
        :setOnClick(onClick)
        :setColors({
            normal = { 0.35, 0.12, 0.12, 1 },
            hover = { 0.45, 0.16, 0.16, 1 },
            pressed = { 0.25, 0.08, 0.08, 1 },
            disabled = { 0.1, 0.1, 0.1, 0.6 },
            border = { 1, 0.6, 0.6, 1 },
            text = { 1, 0.9, 0.9, 1 },
            focus = { 1, 0.4, 0.4, 1 }
        })

    self.root:add(b1)
    self.root:add(b2)
    self.root:add(b3)
    self.root:add(b4)
    self.root:add(b5)

    self.buttons = { b1, b2, b3, b4, b5 }
    self.b4 = b4

    -- 应用主题样式至整棵树（自定义 b5 不会被覆盖）
    if self.app and self.app.style then
        self.app.style:applyTree(self.root)
    end

    -- 演示：点击 "Wide Button" 时做宽度补间
    b4.onClick = function(btn)
        self.log:add("[animate] Tween width to 280")
        btn:animate(self.app, "w", 280, 0.6, "quadOut")
        btn:animate(self.app, "w", 220, 0.6, "quadIn")
    end
end

function ButtonTestScene:update(dt)
    -- 无复杂逻辑
end

function ButtonTestScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Button Test Scene", 40, 16)

    if self.root and self.root.draw then self.root:draw() end
    if self.log and self.log.draw then self.log:draw() end
end

function ButtonTestScene:keypressed(key)
    if key == "f1" then
        if self.app and self.app.switchScene then self.app:switchScene("main") end
        return
    end
    if key == "p" and self.b4 then
        self.b4:pauseAnimations(self.app, "w")
        if self.log then self.log:add("[pause] b4 width tween") end
        return
    end
    if key == "r" and self.b4 then
        self.b4:resumeAnimations(self.app, "w")
        if self.log then self.log:add("[resume] b4 width tween") end
        return
    end
    -- 让获得焦点的按钮响应键盘激活
    for i = 1, #self.buttons do
        local b = self.buttons[i]
        if b.keypressed then b:keypressed(key) end
    end
end

function ButtonTestScene:mousemoved(x, y)
    for i = 1, #self.buttons do
        local b = self.buttons[i]
        if b.mousemoved then b:mousemoved(x, y) end
    end
end

function ButtonTestScene:mousepressed(x, y, button)
    for i = 1, #self.buttons do
        local b = self.buttons[i]
        if b.mousepressed then b:mousepressed(x, y, button) end
    end
end

function ButtonTestScene:mousereleased(x, y, button)
    for i = 1, #self.buttons do
        local b = self.buttons[i]
        if b.mousereleased then b:mousereleased(x, y, button) end
    end
end

return ButtonTestScene
