-- Engine/Scenes/LoadingScene.lua
-- 引擎默认加载场景：显示简单的加载提示并等待游戏注册入口

local Scene = require("Engine.Core.Scene")
local ProgressBar = require("Engine.UI.ProgressBar")

local LoadingScene = Scene:extend()

function LoadingScene:enter()
    self.t = 0
    self.msg = "Loading"
    self.dots = 0
    self.progress = 0
    self.platformInfo = nil

    -- 监听平台信息
    if self.app and self.app.on then
        self._h_platform = self.app:on("platform:ready", function(info)
            self.platformInfo = info
        end, { target = self })

        -- 接收加载状态/进度/完成事件（由 Game 入口驱动）
        self._h_status = self.app:on("loading:status", function(text)
            if type(text) == "string" and #text > 0 then self.msg = text end
        end, { target = self })
        self._h_progress = self.app:on("loading:progress", function(p)
            p = tonumber(p) or 0
            if p < 0 then p = 0 elseif p > 1 then p = 1 end
            -- 平滑过渡到目标进度
            if self.app and self.app.animation then
                self.app.animation:animate(self, function(obj, v) obj.progress = v end, p, 0.2, "quadOut", { from = self.progress })
            else
                self.progress = p
            end
        end, { target = self })
        self._h_done = self.app:on("loading:done", function(sceneName)
            local target = type(sceneName) == "string" and sceneName or "main"
            if self.app and self.app.switchScene then self.app:switchScene(target) end
        end, { target = self })
    end
end

function LoadingScene:leave()
    if self.app and self.app.off then
        if self._h_platform then self.app:off("platform:ready", self._h_platform) end
        if self._h_status then self.app:off("loading:status", self._h_status) end
        if self._h_progress then self.app:off("loading:progress", self._h_progress) end
        if self._h_done then self.app:off("loading:done", self._h_done) end
        self._h_platform, self._h_status, self._h_progress, self._h_done = nil, nil, nil, nil
    end
end

function LoadingScene:update(dt)
    self.t = self.t + dt
    if self.t >= 0.4 then
        self.t = 0
        self.dots = (self.dots + 1) % 4
    end
end

function LoadingScene:draw()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local text = self.msg .. string.rep(".", self.dots)
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local tw = font:getWidth(text)
    local th = font:getHeight()
    local cx, cy = (w - tw) / 2, (h - th) / 2 - 20
    love.graphics.print(text, cx, cy)

    -- 进度条（使用 UI 组件）
    if not self.progressBar then
        self.progressBar = ProgressBar(0, 0, 320, 12)
        if self.app and self.app.style then self.app.style:applyProgressBar(self.progressBar) end
    end
    local bx, by = (w - self.progressBar.w) / 2, cy + th + 16
    self.progressBar:setPosition(bx, by)
    self.progressBar:setValue(self.progress)
    self.progressBar:draw()

    -- 平台信息（可选显示）
    if self.platformInfo then
        local infoText = string.format("OS: %s  DPI: %.2f", tostring(self.platformInfo.os), tonumber(self.platformInfo.dpiScale or 1) or 1)
        love.graphics.print(infoText, bx, by + self.progressBar.h + 10)
    end
end

return LoadingScene
