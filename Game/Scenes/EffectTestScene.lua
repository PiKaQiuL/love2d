-- Game/Scenes/EffectTestScene.lua
-- 效果树演示场景：条件 + 时长 + 并行

local Scene = require("Engine.Core.Scene")
local TextPanel = require("Game.UI.TextPanel")
local Effect = require("Engine.Effects.EffectTree")

local EffectTestScene = Scene:extend()

function EffectTestScene:enter()
    if self.app and self.app.logger then self.app.logger:info("EffectTestScene enter") end
    self.log = TextPanel(10, 140, 580)
    self.log:add("EffectTest: Press [Space] to toggle condition.")
    self.log:add("EffectTest: Press [Esc] to return to Main.")

    -- 黑板：控制条件与计数
    local bb = { active = false, counter = 0 }

    -- 一个简单的持续效果：每 tick 增加计数，始终返回 Running
    local TickEffect = Effect.Node:extend()
    function TickEffect:update(dt, bb2)
        bb2.counter = (bb2.counter or 0) + 1
        return Effect.Status.Running
    end

    -- 条件 + 时长 效果
    local gated = Effect.Condition({
        predicate = function(bb2) return bb2.active == true end,
        child = Effect.Duration({ duration = 3.0, child = TickEffect({ name = "tick" }) })
    })

    -- 并行：左侧 gated，右侧为独立 2s 效果
    local side = Effect.Duration({ duration = 2.0, child = TickEffect({ name = "tick2" }) })
    local root = Effect.Parallel({ children = { gated, side } })

    self.tree = Effect.Tree(root, bb)

    -- 周期日志输出
    local step = 0.2
    local id
    id = self.app.timer:every(step, function()
        local s = self.tree:tick(step)
        self.log:add(string.format("[effect] tick => %s, active=%s, counter=%d", tostring(s), tostring(bb.active), bb.counter or 0))
        if s ~= Effect.Status.Running then
            self.log:add("[effect] finished. Press Space to re-activate and re-run.")
            self.tree:reset()
        end
    end)

    -- 记录计时器 id 以便离场清理
    self._timerId = id

    -- 输入：空格切换条件
    self._h_key = self.app:on("input:keypressed", function(key)
        if key == "space" then
            bb.active = not bb.active
            self.log:add(string.format("[input] space -> active=%s", tostring(bb.active)))
        elseif key == "escape" then
            if self.app and self.app.switchScene then self.app:switchScene("main") end
        end
    end, { target = self })
end

function EffectTestScene:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("Effect Test Scene", 10, 10)
    self.log:draw()
end

function EffectTestScene:leave()
    if self.app and self.app.logger then self.app.logger:info("EffectTestScene leave") end
    if self._h_key then self.app:off("input:keypressed", self._h_key) end
    if self._timerId then self.app.timer:cancel(self._timerId) end
end

return EffectTestScene
