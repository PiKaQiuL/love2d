-- Game/Scenes/ColorTestScene.lua
-- 颜色工具类集成测试场景

local Scene = require("Engine.Core.Scene")
local Panel = require("Engine.UI.Panel")
local Label = require("Engine.UI.Label")
local Color = require("Engine.Utils.Color")
local ColorHelper = require("Engine.Utils.ColorHelper")

local ColorTestScene = Scene:extend()

function ColorTestScene:enter()
    if self.app and self.app.logger then 
        self.app.logger:info("ColorTestScene enter") 
    end

    -- 测试 1：使用 Color 对象创建面板
    self.panel1 = Panel()
        :setPosition(50, 50)
        :setSize(150, 80)
        :setFill(Color.BLUE:clone():setAlpha(0.8))
        :setBorder(Color.CYAN)
        :setBorderWidth(2)
    
    local label1 = Label()
        :setText("Color Object")
        :setPosition(10, 30)
        :setColor(Color.WHITE)
    self.panel1:add(label1)

    -- 测试 2：使用十六进制字符串
    self.panel2 = Panel()
        :setPosition(220, 50)
        :setSize(150, 80)
        :setFill(Color.fromHex("#FF6B35"))  -- 橙色
        :setBorder(Color.fromHex("#FFF"))   -- 白色
        :setBorderWidth(2)
    
    local label2 = Label()
        :setText("Hex Color")
        :setPosition(10, 30)
        :setColor(Color.BLACK)
    self.panel2:add(label2)

    -- 测试 3：使用 HSV
    local hsvColor = Color.fromHSV(280, 0.6, 0.9, 1.0)  -- 紫色
    self.panel3 = Panel()
        :setPosition(390, 50)
        :setSize(150, 80)
        :setFill(hsvColor)
        :setBorder(Color.WHITE)
        :setBorderWidth(2)
    
    local label3 = Label()
        :setText("HSV Color")
        :setPosition(10, 30)
        :setColor(Color.WHITE)
    self.panel3:add(label3)

    -- 测试 4：颜色操作（亮度调整）
    local baseColor = Color.GREEN
    self.panel4 = Panel()
        :setPosition(50, 150)
        :setSize(150, 80)
        :setFill(baseColor:clone():brightness(0.5))  -- 更暗的绿色
        :setBorder(Color.WHITE)
    
    local label4 = Label()
        :setText("Brightness 0.5")
        :setPosition(10, 30)
        :setColor(Color.WHITE)
    self.panel4:add(label4)

    -- 测试 5：颜色插值（渐变）
    local color1 = Color.RED
    local color2 = Color.YELLOW
    local lerpColor = color1:lerp(color2, 0.5)  -- 橙色
    self.panel5 = Panel()
        :setPosition(220, 150)
        :setSize(150, 80)
        :setFill(lerpColor)
        :setBorder(Color.WHITE)
    
    local label5 = Label()
        :setText("Red→Yellow 50%")
        :setPosition(10, 30)
        :setColor(Color.BLACK)
    self.panel5:add(label5)

    -- 测试 6：预设颜色
    self.panel6 = Panel()
        :setPosition(390, 150)
        :setSize(150, 80)
        :setFill(Color.MAGENTA)
        :setBorder(Color.WHITE)
    
    local label6 = Label()
        :setText("Preset: MAGENTA")
        :setPosition(10, 30)
        :setColor(Color.WHITE)
    self.panel6:add(label6)

    -- 测试 7：颜色取反
    self.panel7 = Panel()
        :setPosition(50, 250)
        :setSize(150, 80)
        :setFill(Color.BLUE:clone():invert())
        :setBorder(Color.WHITE)
    
    local label7 = Label()
        :setText("Inverted Blue")
        :setPosition(10, 30)
        :setColor(Color.BLACK)
    self.panel7:add(label7)

    -- 测试 8：灰度化
    self.panel8 = Panel()
        :setPosition(220, 250)
        :setSize(150, 80)
        :setFill(Color.ORANGE:clone():grayscale())
        :setBorder(Color.WHITE)
    
    local label8 = Label()
        :setText("Grayscale Orange")
        :setPosition(10, 30)
        :setColor(Color.WHITE)
    self.panel8:add(label8)

    -- 测试 9：RGB255 格式
    self.panel9 = Panel()
        :setPosition(390, 250)
        :setSize(150, 80)
        :setFill(Color.fromRGB255(255, 105, 180))  -- 粉色
        :setBorder(Color.WHITE)
    
    local label9 = Label()
        :setText("RGB255 Pink")
        :setPosition(10, 30)
        :setColor(Color.WHITE)
    self.panel9:add(label9)

    -- 动画测试：颜色循环
    self.hue = 0
    self.animPanel = Panel()
        :setPosition(50, 350)
        :setSize(490, 60)
        :setBorder(Color.WHITE)
    
    local animLabel = Label()
        :setText("Press [Space] for HSV animation | [ESC] to return")
        :setPosition(10, 20)
        :setColor(Color.WHITE)
    self.animPanel:add(animLabel)

    self.animating = false

    -- 键盘事件
    self._h_key = self.app:on("input:keypressed", function(key)
        if key == "space" then
            self.animating = not self.animating
            if self.app and self.app.logger then 
                self.app.logger:info("Animation: " .. tostring(self.animating)) 
            end
        elseif key == "escape" then
            if self.app and self.app.scenes then
                self.app:switchScene("main")
            end
        end
    end)
end

function ColorTestScene:update(dt)
    if self.animating then
        self.hue = (self.hue + dt * 120) % 360
        local animColor = Color.fromHSV(self.hue, 0.8, 0.9)
        self.animPanel:setFill(animColor)
    end
end

function ColorTestScene:draw()
    love.graphics.setColor(0.05, 0.05, 0.08, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- 标题
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Color Utility Integration Test", 50, 20)
    
    -- 绘制所有面板
    if self.panel1 then self.panel1:draw() end
    if self.panel2 then self.panel2:draw() end
    if self.panel3 then self.panel3:draw() end
    if self.panel4 then self.panel4:draw() end
    if self.panel5 then self.panel5:draw() end
    if self.panel6 then self.panel6:draw() end
    if self.panel7 then self.panel7:draw() end
    if self.panel8 then self.panel8:draw() end
    if self.panel9 then self.panel9:draw() end
    if self.animPanel then self.animPanel:draw() end
end

function ColorTestScene:leave()
    if self.app and self.app.logger then 
        self.app.logger:info("ColorTestScene leave") 
    end
    if self._h_key then 
        self.app:off("input:keypressed", self._h_key) 
    end
end

return ColorTestScene
