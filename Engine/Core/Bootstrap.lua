-- Engine/Bootstrap.lua
-- 引导应用与场景注册
-- 模块：引导器
-- 功能：创建 App，接入输入系统并注册/切换到主场景
-- 依赖：Engine.App, Engine.Scene, Engine.Input
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 函数：
-- - boot(): 创建 App，接入输入系统并注册主场景

local App = require("Engine.Core.App")
local Scene = require("Engine.Core.Scene")
local Input = require("Engine.Systems.Input")
local Platform = require("Engine.Systems.Platform")
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

    -- 加载示例场景
    local MainScene = require("Game.Scenes.MainScene")
    app.scenes:register("main", MainScene(app))
    app:switchScene("main")

    return app
end

return {
    boot = boot
}
