-- Engine/Config.lua
-- 项目配置集中，减少散落的硬编码
--
-- 字段说明：
-- - FPS: number 目标帧率（用于自定义 love.run）
-- - UI.spacing: number UI 控件默认间距
-- - UI.padding: number UI 控件默认内边距

local Config = {
    FPS = 60,
    UI = {
        spacing = 8,
        padding = 6,
        fontSize = 14
    },
    -- 存档默认格式："lua" | "json"
    Storage = {
        format = "lua" -- 可改为 "json" 以使用 JSON 存档
    }
}

return Config
