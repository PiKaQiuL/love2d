-- Engine/Bootstrap.lua
-- 引导应用与场景注册
-- 模块：引导器
-- 功能：创建 App，接入输入与平台系统，注册引擎默认加载场景；随后加载 Game 侧入口完成场景注册
-- 依赖：Engine.App, Engine.Scene, Engine.Input
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 函数：
-- - boot(): 创建 App，接入输入系统并注册主场景

local App = require("Engine.Core.App")
local Scene = require("Engine.Core.Scene")
local LoadingScene = require("Engine.Scenes.LoadingScene")
local Input = require("Engine.Systems.Input")
local Platform = require("Engine.Systems.Platform")
local Animation = require("Engine.Systems.Animation")
local Logger = require("Engine.Systems.Logger")
local Config = require("Engine.Core.Config")

local function loadDefaultFont()
    if not love or not love.graphics or not love.graphics.newFont then return end
    local size = (Config and Config.UI and Config.UI.fontSize) or 14
    local font
    local tryPaths = {
        "Assets/fonts/msyhl.ttc",
        -- "Assets/fonts/msyh.ttc",
        -- "Assets/fonts/msyh.ttf",
        -- "Assets/fonts/NotoSans-Regular.ttf",
        -- "Assets/fonts/JetBrainsMono-Regular.ttf"
    }
    if love.filesystem and love.filesystem.getInfo then
        for i = 1, #tryPaths do
            local p = tryPaths[i]
            if love.filesystem.getInfo(p) then
                local ok, f = pcall(love.graphics.newFont, p, size)
                if ok and f then
                    font = f; break
                end
            end
        end
    end
    if not font then
        font = love.graphics.newFont(size)
    end
    love.graphics.setFont(font)
end

local function boot()
    local app = App()
    -- 设置默认字体（优先 Assets/fonts 中的可用字体）
    loadDefaultFont()

    -- 默认接入输入系统，并暴露到 app.input 便于查询
    local input = Input()
    app:addSystem(input)
    app.input = input
    -- 平台系统：检测 OS/DPI 等并广播 platform:ready
    app:addSystem(Platform())
    -- 动画系统：补间轨道管理
    local anim = Animation()
    app:addSystem(anim)
    app.animation = anim

    -- 日志系统：写入项目 Logs 目录
    local logger = Logger({ level = 2 }) -- 默认 info
    app:addSystem(logger)
    app.logger = logger

    -- 引擎默认加载场景（Loading）
    app.scenes:register("loading", LoadingScene(app))
    app:switchScene("loading")

    -- 下一帧延后加载 Game 入口，交由 Game 注册并切换到其主场景
    app.timer:after(0, function()
        local ok, gameBoot = pcall(require, "Game.Bootstrap")
        if ok and gameBoot and type(gameBoot) == "function" then
            gameBoot(app)
        else
            -- 若 Game 入口缺失，保持加载场景并给出提示
            if app.logger then app.logger:warn("Game.Bootstrap not found or invalid; stay at loading scene.") end
        end
    end)

    return app
end

return {
    boot = boot
}
