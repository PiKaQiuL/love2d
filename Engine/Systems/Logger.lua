-- Engine/Systems/Logger.lua
-- 简易日志系统：将日志写入项目路径下的 Logs 目录

local System = require("Engine.Core.System")

---
---@class Logger : System
---@field level integer @最小日志级别（1=debug,2=info,3=warn,4=error）
---@field projectDir string
---@field logsDir string
---@field filePath string
---@field fh file*|nil
local Logger = System:extend()

local LEVELS = { debug = 1, info = 2, warn = 3, error = 4 }

local function sep()
    return package.config and package.config:sub(1,1) or "/"
end

local function now()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local function ensureDir(dir)
    local s = sep()
    if s == "\\" then
        -- Windows 使用 PowerShell 创建目录（避免重复提示）
        dir = dir:gsub("/", "\\")
        local cmd = string.format(
            "powershell -NoProfile -Command \"if (!(Test-Path -LiteralPath '%s')) { New-Item -ItemType Directory -Path '%s' | Out-Null }\"",
            dir, dir
        )
        os.execute(cmd)
    else
        os.execute(string.format('mkdir -p "%s"', dir))
    end
end

function Logger:init(opts)
    self.level = (opts and opts.level) or LEVELS.info
    local base = love.filesystem.getSourceBaseDirectory()
    local src = love.filesystem.getSource()
    local s = sep()
    -- 兼容 getSource 返回绝对路径的情况
    local function isAbs(p)
        return type(p) == "string" and (p:match("^%a:[/\\]") or p:sub(1,1) == "/")
    end
    if isAbs(src) then
        self.projectDir = src
    else
        self.projectDir = base .. s .. src
    end
    -- 归一化分隔符
    if s == "\\" then
        self.projectDir = self.projectDir:gsub("/", "\\")
    else
        self.projectDir = self.projectDir:gsub("\\", "/")
    end
    self.logsDir = self.projectDir .. s .. "Logs"
    ensureDir(self.logsDir)
    local date = os.date("%Y-%m-%d")
    self.filePath = self.logsDir .. s .. (opts and opts.filename or ("game-" .. date .. ".log"))
    if s == "\\" then
        self.logsDir = self.logsDir:gsub("/", "\\")
        self.filePath = self.filePath:gsub("/", "\\")
    else
        self.logsDir = self.logsDir:gsub("\\", "/")
        self.filePath = self.filePath:gsub("\\", "/")
    end
    -- 打开文件追加写入
    local ok, fh = pcall(io.open, self.filePath, "a")
    if ok and fh then
        self.fh = fh
        self:info(string.format("Logger initialized. file=%s", self.filePath))
    else
        print("[logger] failed to open log file:", self.filePath)
    end
end

function Logger:destroy()
    if self.fh then
        self.fh:flush()
        self.fh:close()
        self.fh = nil
    end
end

---@param minLevel integer|nil
function Logger:setLevel(minLevel)
    if type(minLevel) == "number" then
        self.level = minLevel
    end
end

---@param level string @"debug"|"info"|"warn"|"error"
---@param msg string
function Logger:log(level, msg)
    local lv = LEVELS[level] or LEVELS.info
    if lv < self.level then return end
    local line = string.format("[%s][%s] %s\n", now(), level:upper(), tostring(msg))
    if self.fh then
        self.fh:write(line)
        self.fh:flush()
    end
    -- 控制台也输出，便于开发时查看
    print(string.format("[log][%s] %s", level, msg))
end

function Logger:debug(msg) self:log("debug", msg) end
function Logger:info(msg) self:log("info", msg) end
function Logger:warn(msg) self:log("warn", msg) end
function Logger:error(msg) self:log("error", msg) end

---@param fmt string
---@param ... any
function Logger:logf(level, fmt, ...)
    self:log(level, string.format(fmt, ...))
end

function Logger:infof(fmt, ...) self:logf("info", fmt, ...) end
function Logger:debugf(fmt, ...) self:logf("debug", fmt, ...) end
function Logger:warnf(fmt, ...) self:logf("warn", fmt, ...) end
function Logger:errorf(fmt, ...) self:logf("error", fmt, ...) end

return Logger
