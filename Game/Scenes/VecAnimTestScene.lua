-- Game/Scenes/VecAnimTestScene.lua
-- 向量与动画综合测试场景

local Scene = require("Engine.Core.Scene")
local Panel = require("Engine.UI.Panel")
local Label = require("Engine.UI.Label")
local Vector2 = require("Engine.Utils.Vector2")

local VecAnimTestScene = Scene:extend()

function VecAnimTestScene:enter()
    if self.app and self.app.logger then self.app.logger:info("VecAnimTest enter") end

    -- 文本说明（使用链式调用）
    self.title = Label()
        :setText("Vec + Animation Test")
        :setPosition(12, 10)
        :setColor(1, 1, 0.6, 1)

    -- 中心与半径
    local ww, wh = love.graphics.getDimensions()
    self.center = Vector2(ww * 0.5, wh * 0.5)
    self.radius = 90

    -- 被动画驱动的面板（中心锚点，使用链式调用）
    self.mover = Panel()
        :setSize(120, 32)
        :setPivotCenter()
    self.moverLabel = Label()
        :setText("moving")
        :setPosition(8, 8)
    self.mover:add(self.moverLabel)

    -- 初始化角度与位置
    self.angle = 0
    local p0 = Vector2.fromAngle(self.angle, self.radius)
    self.mover:setPositionV(self.center + p0)

    -- 启动角度动画：0->2π，再 yoyo 回 0，循环
    if self.app and self.app.animation then
        self.app.animation:animate(self, function(_, value)
            self.angle = value
            local p = Vector2.fromAngle(value, self.radius)
            self.mover:setPositionV(self.center + p)
        end, math.pi * 2, 3.0, "cubicInOut", { from = 0, ["repeat"] = -1, yoyo = true })
    end

    -- 向量方法快速验证
    self.vecLogs = {}
    local function log(s) self.vecLogs[#self.vecLogs+1] = s end
    local a = Vector2(3, 4)
    log(string.format("len(3,4)=%.2f", a:length()))
    log(string.format("len2(3,4)=%.2f", a:length2()))
    local n = a:normalized()
    log(string.format("norm(3,4)=(%.2f,%.2f), len=%.2f", n.x, n.y, n:length()))
    local d = Vector2(1,0) * Vector2(0,1)  -- 点积
    log(string.format("dot((1,0),(0,1))=%.2f", d))
    local l = Vector2(0,0):lerp(Vector2(10,0), 0.25)
    log(string.format("lerp((0,0)->(10,0),0.25)=(%.2f,%.2f)", l.x, l.y))
    local c = Vector2(10,0):clampLength(3)
    log(string.format("clampLength((10,0),3)=(%.2f,%.2f), len=%.2f", c.x, c.y, c:length()))

    -- 热键提示（使用链式调用）
    self.hint = Label()
        :setText("[F5] back to Main  |  [P] pause  [R] resume")
        :setPosition(12, 30)
        :setColor(0.8, 0.9, 1, 1)
end

function VecAnimTestScene:keypressed(key)
    if key == "f5" then
        if self.app and self.app.logger then self.app.logger:info("Switch to main scene") end
        if self.app then self.app:switchScene("main") end
        return
    end
    if key == "p" and self.app and self.app.animation then
        self.app.animation:pause(self)
        return
    end
    if key == "r" and self.app and self.app.animation then
        self.app.animation:resume(self)
        return
    end
end

function VecAnimTestScene:draw()
    love.graphics.setColor(1,1,1,1)
    if self.title and self.title.draw then self.title:draw() end
    if self.hint and self.hint.draw then self.hint:draw() end

    -- 绘制圆心与轨迹参考
    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.circle("line", self.center.x, self.center.y, self.radius)
    love.graphics.setColor(1,1,1,1)

    -- 绘制向量日志
    local x, y = 12, 56
    for i = 1, #self.vecLogs do
        love.graphics.print(self.vecLogs[i], x, y)
        y = y + 16
    end

    -- 绘制移动面板
    if self.mover and self.mover.draw then self.mover:draw() end
end

function VecAnimTestScene:leave()
    if self.app and self.app.animation then self.app.animation:stop(self) end
end

return VecAnimTestScene
