-- 入口优化：使用 Bootstrap 接线，并统一委托事件
-- 模块：入口主文件
-- 功能：初始化 App，并委托 Love 事件；可选自定义主循环
-- 依赖：Engine.Bootstrap, Engine.Config
-- 作者：Team
-- 修改时间：2025-12-21
local Bootstrap = require("Engine.Core.Bootstrap")
local Config = require("Engine.Core.Config")

local app
local handlers -- 延后创建的输入回调包装
-- 目标帧率（来自集中配置）
local TARGET_FPS = Config.FPS or 60

function love.update(dt)
    if app then app:update(dt) end
end

function love.draw()
    if app then app:draw() end
end

function love.keypressed(key, scancode, isrepeat)
    if app and app.keypressed then app:keypressed(key, scancode, isrepeat) end
end

function love.keyreleased(key, scancode)
    if app and app.keyreleased then app:keyreleased(key, scancode) end
end

function love.textinput(text)
    if app and app.textinput then app:textinput(text) end
end

function love.mousepressed(x, y, button, presses)
    if app and app.mousepressed then app:mousepressed(x, y, button, presses) end
end

function love.mousereleased(x, y, button, presses)
    if app and app.mousereleased then app:mousereleased(x, y, button, presses) end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if app and app.mousemoved then app:mousemoved(x, y, dx, dy, istouch) end
end

function love.wheelmoved(dx, dy)
    if app and app.wheelmoved then app:wheelmoved(dx, dy) end
end

-- 可选：自定义主循环，稳定帧率并限制 dt
-- - 读取 TARGET_FPS 控制休眠节奏
-- - 限制 dt 最大值，避免数值系统跳变（建议 0.1～0.2）
-- 如需关闭此自定义循环，注释掉此函数即可回退到默认 love.run
function love.run()
    ---@diagnostic disable-next-line: undefined-field
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- if love.timer then love.timer.step() end

    -- 主循环
    local dt = 0
    local target = 1 / TARGET_FPS
    local run_time = 0
    -- 使用 LÖVE 内置事件分发表
---@diagnostic disable-next-line: undefined-field
    handlers = love.handlers
    return function()
        run_time = love.timer.getTime()
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    ---@diagnostic disable-next-line: undefined-field
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                local fn = handlers and handlers[name]
                if fn then fn(a, b, c, d, e, f) end
            end
        end

        if love.timer then dt = love.timer.step() else dt = target end
        -- 限制过大 dt，避免跳帧导致数值过快（资源/触发系统累计过多）
        if dt > 0.1 then dt = 0.1 end

        if love.update then love.update(dt) end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.draw()
            love.graphics.present()
        end

        if love.timer then
            local sleep = target - dt
            if sleep > 0 then love.timer.sleep(sleep) end
        end
    end
end

function love.load(...)
    app = Bootstrap.boot()
end
