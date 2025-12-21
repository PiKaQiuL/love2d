-- Engine/Platform.lua
-- 平台系统：检测操作系统、DPI、路径与常用平台能力
-- 模块：平台适配系统
-- 功能：提供跨平台的查询与便捷方法，并在初始化时广播平台信息
-- 依赖：Engine.System
-- 作者：Team
-- 修改时间：2025-12-22
--
-- 事件：
-- - platform:ready(osName, info) 在 init 完成后触发
--
-- 方法：
-- - getOS() -> string
-- - isWindows/isMac/isLinux/isAndroid/isiOS
-- - dpiScale() -> number
-- - userDir() / saveDir()
-- - openURL(url) -> boolean
-- - copy(text) -> boolean
-- - paste() -> string|nil

local System = require("Engine.Core.System")

---@class Platform : System
---@field _os string
---@field info table
local Platform = System:extend()

function Platform:init()
    local osName = love.system and love.system.getOS and love.system.getOS() or "unknown"
    self._os = osName
    -- 兼容不同 LÖVE 版本：语言可能没有相关 API，做安全探测
    local lang
    if love.system then
---@diagnostic disable-next-line: undefined-field
        local getLanguage = love.system.getLanguage
---@diagnostic disable-next-line: undefined-field
        local getLocale = love.system.getLocale
        if type(getLanguage) == "function" then
            lang = getLanguage()
        elseif type(getLocale) == "function" then
            lang = getLocale()
        else
            lang = nil
        end
    end
    self.info = {
        os = osName,
        dpi = love.window and love.window.getDPIScale and love.window.getDPIScale() or 1,
        cores = love.system and love.system.getProcessorCount and love.system.getProcessorCount() or nil,
        language = lang,
        version = love.getVersion and love.getVersion() or nil
    }
    if self.app and self.app.emit then
        self.app:emit("platform:ready", osName, self.info)
    end
end

function Platform:getOS() return self._os end
function Platform:isWindows() return self._os == "Windows" end
function Platform:isMac() return self._os == "OS X" end
function Platform:isLinux() return self._os == "Linux" end
function Platform:isAndroid() return self._os == "Android" end
function Platform:isiOS() return self._os == "iOS" end

function Platform:dpiScale()
    local window = love and rawget(love, "window")
    local getDPIScale = window and rawget(window, "getDPIScale")
    return (type(getDPIScale) == "function" and getDPIScale()) or 1
end

function Platform:userDir()
    local filesystem = love and rawget(love, "filesystem")
    local getUserDirectory = filesystem and rawget(filesystem, "getUserDirectory")
    return (type(getUserDirectory) == "function" and getUserDirectory()) or nil
end

function Platform:saveDir()
    local filesystem = love and rawget(love, "filesystem")
    local getSaveDirectory = filesystem and rawget(filesystem, "getSaveDirectory")
    return (type(getSaveDirectory) == "function" and getSaveDirectory()) or nil
end

function Platform:openURL(url)
    local system = love and rawget(love, "system")
    local openURL = system and rawget(system, "openURL")
    return (type(openURL) == "function" and openURL(url)) or false
end

function Platform:copy(text)
    local system = love and rawget(love, "system")
    local setClipboardText = system and rawget(system, "setClipboardText")
    if type(setClipboardText) == "function" then
        setClipboardText(text or "")
        return true
    end
    return false
end

function Platform:paste()
    local system = love and rawget(love, "system")
    local getClipboardText = system and rawget(system, "getClipboardText")
    return (type(getClipboardText) == "function" and getClipboardText()) or nil
end

return Platform
