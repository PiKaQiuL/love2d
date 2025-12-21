-- Engine/UI/Factory.lua
-- UI 工厂：统一创建常用控件，并可选自动应用样式
-- 用法示例：
--   local Factory = require("Engine.UI.Factory")
--   local ui = Factory.new(app) -- 传入 App，可自动应用 app.style
--   local btn = ui:button({ text = "OK", x = 20, y = 20, onClick = function() ... end })
--   local panel = ui:panel({ x = 10, y = 10, w = 200, h = 120 })
--   panel:add(btn)

local Label = require("Engine.UI.Label")
local Panel = require("Engine.UI.Panel")
local Button = require("Engine.UI.Button")
local TextInput = require("Engine.UI.TextInput")
local ListView = require("Engine.UI.ListView")
local Layout = require("Engine.UI.Layout")
local Style = require("Engine.UI.Style")

-- 单例实例（可选）：通过 Factory.get(appOrStyle) 获取并懒初始化
local _singleton ---@type UIFactory|nil

---
---@class UIFactory
---@field style Style|nil
---@field _creators table<string, fun(opts:table, style:Style|nil):any>
local UIFactory = {}
UIFactory.__index = UIFactory

--- 创建与样式绑定的 UI 工厂
---@param appOrStyle App|Style|nil App 或 Style；若为空则不自动应用主题
---@return UIFactory
function UIFactory.new(appOrStyle)
    local style = nil
    if appOrStyle then
        style = appOrStyle.style or appOrStyle
    end
    return setmetatable({ style = style, _creators = {} }, UIFactory)
end

--- 获取单例工厂（懒加载）
---@param appOrStyle App|Style|nil
---@return UIFactory
function UIFactory.get(appOrStyle)
    if not _singleton then
        _singleton = UIFactory.new(appOrStyle)
    end
    return _singleton
end

--- 当前单例实例（若尚未创建返回 nil）
---@return UIFactory|nil
function UIFactory.instance()
    return _singleton
end

--- 注册自定义组件构造器
---@param name string
---@param fn fun(opts:table, style:Style|nil):any
function UIFactory:register(name, fn)
    self._creators[name] = fn
end

--- 使用已注册的构造器创建组件
---@param name string
---@param opts table|nil
---@return any
function UIFactory:create(name, opts)
    local fn = self._creators[name]
    if not fn then error("UIFactory: creator not found: " .. tostring(name)) end
    return fn(opts or {}, self.style)
end

--- 创建 Label
---@param opts table @{ text:string|nil, x:number|nil, y:number|nil, color:Color|nil, font:love.Font|nil }
---@return Label
function UIFactory:label(opts)
    opts = opts or {}
    local inst = Label(opts.text or "", opts.x or 0, opts.y or 0, opts.color)
    if opts.font then inst:setFont(opts.font) end
    if self.style and self.style.applyLabel then self.style:applyLabel(inst) end
    return inst
end

--- 创建 Panel
---@param opts table @{ x:number|nil, y:number|nil, w:number|nil, h:number|nil, fill:Color|nil, border:Color|nil, borderWidth:number|nil, padding:number|nil }
---@return Panel
function UIFactory:panel(opts)
    opts = opts or {}
    local inst = Panel(opts.x or 0, opts.y or 0, opts.w or 100, opts.h or 60, opts)
    if self.style and self.style.applyPanel then self.style:applyPanel(inst) end
    return inst
end

--- 创建 Button
---@param opts table @{ text:string|nil, x:number|nil, y:number|nil, w:number|nil, h:number|nil, onClick:fun(self:Button)|nil, disabled:boolean|nil }
---@return Button
function UIFactory:button(opts)
    opts = opts or {}
    local inst = Button(opts.text or "Button", opts.x or 0, opts.y or 0, opts.w or 120, opts.h or 30, opts)
    if self.style and self.style.applyButton then self.style:applyButton(inst) end
    return inst
end

--- 创建 TextInput
---@param opts table @{ x:number|nil, y:number|nil, w:number|nil, h:number|nil, placeholder:string|nil }
---@return TextInput
function UIFactory:textInput(opts)
    opts = opts or {}
    local inst = TextInput(opts.x or 0, opts.y or 0, opts.w or 180, opts.h or 28, opts)
    if self.style and self.style.applyTextInput then self.style:applyTextInput(inst) end
    return inst
end

--- 创建 ListView
---@param opts table @{ x:number|nil, y:number|nil, w:number|nil, itemHeight:number|nil, maxVisible:integer|nil, padding:number|nil }
---@return ListView
function UIFactory:listView(opts)
    opts = opts or {}
    local inst = ListView(opts.x or 0, opts.y or 0, opts.w or 240, opts.itemHeight or 18, opts)
    if self.style and self.style.applyListView then self.style:applyListView(inst) end
    return inst
end

--- 创建 Layout
---@param opts table @{ x:number|nil, y:number|nil, w:number|nil, h:number|nil, direction:string|nil, spacing:number|nil, padding:number|table|nil, align:string|nil, justify:string|nil, wrap:boolean|nil, clip:boolean|nil, autoSize:boolean|nil }
---@return Layout
function UIFactory:layout(opts)
    opts = opts or {}
    local inst = Layout(opts.x or 0, opts.y or 0, opts.w or 300, opts.h or 200, opts)
    if self.style and self.style.applyLayout then self.style:applyLayout(inst) end
    return inst
end

---@class UIFactoryModule
---@field new fun(appOrStyle:App|Style|nil):UIFactory
---@field get fun(appOrStyle:App|Style|nil):UIFactory
---@field instance fun():UIFactory|nil
local M = {
    new = UIFactory.new,
    get = UIFactory.get,
    instance = UIFactory.instance
}
return M
