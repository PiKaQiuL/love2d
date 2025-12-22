-- Game/Scenes/MainScene.lua
-- 示例主场景：资源增长 + 文本面板

local Scene = require("Engine.Core.Scene")
local ResourceSystem = require("Game.Systems.ResourceSystem")
local TextPanel = require("Game.UI.TextPanel")
local Panel = require("Engine.UI.Panel")
local Label = require("Engine.UI.Label")
local ListView = require("Engine.UI.ListView")
local Input = require("Engine.Systems.Input")

local MainScene = Scene:extend()

function MainScene:enter()
    if self.app and self.app.logger then self.app.logger:info("MainScene enter") end
    -- 资源系统
    self.resources = ResourceSystem()
    self.resources:addResource("gold", { amount = 0, rate = 1, display = "Gold" })
    self.resources:addResource("wood", { amount = 10, rate = 0.5, display = "Wood" })
    self.app:addSystem(self.resources)

    -- 文本面板
    self.log = TextPanel(10, 140, 580)
    self.log:add("Press [Space] to log a message.")

    -- 示例 Panel：启用剪裁，内部子元素超出时不溢出
    self.demoPanel = Panel(400, 40, 160, 80)
    for i = 1, 10 do
        local lbl = Label("Item " .. i, 6, 6 + (i - 1) * 18)
        self.demoPanel:add(lbl)
    end

    -- 可滚动列表示例：与剪裁结合
    self.scrollList = ListView(400, 140, 200, 18, { maxVisible = 6 })
    for i = 1, 30 do
        self.scrollList:add("Row " .. i)
    end

    -- 输入系统：优先使用 Bootstrap 提供的全局实例，避免重复
    if not self.input then
        if self.app and self.app.input then
            self.input = self.app.input
        else
            self.input = Input()
            self.app:addSystem(self.input)
            -- 同步为全局，便于其他场景/系统查询复用
            self.app.input = self.input
        end
    end

    -- 事件日志：键盘/鼠标
    self._h_key = self.app:on("input:keypressed", function(key)
        self.log:add("[key] " .. tostring(key))
        if self.app and self.app.logger then self.app.logger:debugf("keypressed: %s", tostring(key)) end
    end)
    self._h_text = self.app:on("input:text", function(t)
        self.log:add("[text] " .. tostring(t))
    end)
    self._h_mpress = self.app:on("input:mousepressed", function(x, y, button)
        self.log:add(string.format("[mouse] btn%d at (%.0f,%.0f)", button, x, y))
        if self.app and self.app.logger then self.app.logger:debugf("mousepressed: btn%d (%.0f,%.0f)", button, x, y) end
        if self.scrollList and self.scrollList.mousepressed and self.scrollList:hitTest(x, y) then
            self.scrollList:mousepressed(x, y, button)
        end
    end)
    -- 鼠标移动：转发到列表用于拖拽
    self._h_mmove = self.app:on("input:mousemoved", function(x, y, dx, dy)
        if self.scrollList and self.scrollList.mousemoved then
            self.scrollList:mousemoved(x, y)
        end
    end)

    -- 鼠标释放：结束拖拽/选择
    self._h_mrelease = self.app:on("input:mousereleased", function(x, y, button)
        if self.scrollList and self.scrollList.mousereleased then
            self.scrollList:mousereleased(x, y, button)
        end
    end)

    -- 鼠标滚轮：在列表区域内滚动
    self._h_wheel = self.app:on("input:wheelmoved", function(dx, dy)
        if self.input and self.scrollList and self.scrollList.hitTest then
            local mx, my = self.input:mousePosition()
            if self.scrollList:hitTest(mx, my) then
                self.scrollList:wheelmoved(dx, dy)
            end
        end
    end)

    -- 每 2 秒打印一次 tick
    self.app.timer:every(2, function()
        self.log:add("Tick at " .. tostring(os.time()))
    end)
end

function MainScene:update(dt)
    -- 查询式输入示例（本帧触发）
    if self.input and self.input:pressed("space") then
        self.log:add("[pressed] space")
    end
    if self.input and self.input:mousePressed(1) then
        local mx, my = self.input:mousePosition()
        self.log:add(string.format("[pressed] mouse1 at (%.0f,%.0f)", mx, my))
    end
end

function MainScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Main Scene", 10, 10)
    self.log:draw()
    -- 绘制示例剪裁面板
    if self.demoPanel and self.demoPanel.draw then
        self.demoPanel:draw()
    end
    -- 绘制可滚动列表
    if self.scrollList and self.scrollList.draw then
        self.scrollList:draw()
    end
end

function MainScene:keypressed(key)
    if key == "f2" then
        if self.app and self.app.logger then self.app.logger:info("Switch to button-test scene") end
        if self.app and self.app.switchScene then self.app:switchScene("button-test") end
        return
    end
    if key == "space" then
        self.log:add("Space pressed: +5 gold")
        if self.app and self.app.logger then self.app.logger:info("Space adds 5 gold") end
        local g = self.resources:get("gold")
        if g then g.amount = g.amount + 5 end
    end
end

function MainScene:leave()
    if self.app and self.app.logger then self.app.logger:info("MainScene leave") end
    -- 清理事件监听器
    if self._h_key then self.app:off("input:keypressed", self._h_key) end
    if self._h_text then self.app:off("input:text", self._h_text) end
    if self._h_mpress then self.app:off("input:mousepressed", self._h_mpress) end
    if self._h_wheel then self.app:off("input:wheelmoved", self._h_wheel) end
    if self._h_mmove then self.app:off("input:mousemoved", self._h_mmove) end
    if self._h_mrelease then self.app:off("input:mousereleased", self._h_mrelease) end
end

return MainScene
