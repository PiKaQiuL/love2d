-- conf.lua
-- 模块：Love2D 配置
-- 功能：设置窗口/渲染等初始参数
-- 依赖：Love2D 框架（love.conf）
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 配置建议：
-- - 分辨率不建议低于 800x600，避免文本布局拥挤
-- - 启用 vsync 降低功耗（文字放置类通常对帧延迟不敏感）
-- - 如使用 MSAA，数值不宜过高以免带来额外开销

function love.conf(t)
	t.window.title = "Love2D Idle Framework"
	t.window.width = 960   -- 建议≥800
	t.window.height = 540  -- 建议≥600（等比为例可设 960x540 或 1280x720）
	t.window.vsync = 1     -- 开启垂直同步以降低功耗
	t.window.msaa = 0      -- 文本 UI 通常无需 MSAA

	t.console = true      -- Windows 可开启调试控制台：true
end
