-- Game/Bootstrap.lua
-- 游戏侧入口：注册游戏场景并切换到主场景

return function(app)
    local Object = require("Engine.Core.Object")

    ---@class Game
    ---@field app App
    Game = Object:extend()

    Game.app = app
    -- 注册游戏场景
    local MainScene = require("Game.Scenes.MainScene")
    app.scenes:register("main", MainScene(app))

    -- 可选：注册更多场景，如按钮测试
    local okBtn, ButtonTestScene = pcall(require, "Game.Scenes.ButtonTestScene")
    if okBtn and ButtonTestScene then
        app.scenes:register("button-test", ButtonTestScene(app))
    end

    -- 切换到主场景
    app:switchScene("main")
end
