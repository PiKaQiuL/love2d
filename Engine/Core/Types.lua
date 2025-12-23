-- Engine/Core/Types.lua
-- 接口类型与通用别名（EmmyLua），仅用于编辑器智能提示与静态分析，不影响运行。
-- 可在需要处引用这些类型名称进行标注。


--- 二维向量
---@class Vec2
---@field x number
---@field y number

--- 矩形
---@class Rect
---@field x number
---@field y number
---@field w number
---@field h number

--- 字体规格（文档类型，实际通常为 love.Font）
---@alias FontSpec love.Font|string|{ name: string, size: number }

--- 颜色类型别名：兼容 Color 对象、数组和带字段表
---@alias ColorLike Color|number[]|{ r: number, g: number, b: number, a: number|nil }

--- 外边距/内边距对象
---@class Margin
---@field l number
---@field t number
---@field r number
---@field b number

---@class Padding
---@field l number
---@field t number
---@field r number
---@field b number

--- 事件相关类型
---@alias EventHandler fun(...):boolean|nil

---@class EventOptions
---@field priority integer|nil
---@field target any|nil

--- UI 列表配色结构
---@class ListColors
---@field bg ColorLike
---@field border ColorLike
---@field text ColorLike
---@field hover ColorLike
---@field selected ColorLike

--- Widget 渲染回调接口（可选实现）
---@class WidgetCallbacks
---@field render fun(self:Widget, x:number, y:number)|nil
---@field preRender fun(self:Widget, x:number, y:number)|nil
---@field postRender fun(self:Widget, x:number, y:number)|nil

--- System 可选回调接口
---@class SystemCallbacks
---@field init fun(self:System)|nil
---@field update fun(self:System, dt:number)|nil
---@field draw fun(self:System)|nil
---@field reset fun(self:System)|nil
---@field keypressed fun(self:System, key:string, scancode:string|nil, isrepeat:boolean|nil)|nil
---@field textinput fun(self:System, text:string)|nil
---@field keyreleased fun(self:System, key:string, scancode:string|nil)|nil
---@field mousepressed fun(self:System, x:number, y:number, button:integer, presses:integer|nil)|nil
---@field mousereleased fun(self:System, x:number, y:number, button:integer, presses:integer|nil)|nil
---@field mousemoved fun(self:System, x:number, y:number, dx:number, dy:number, istouch:boolean|nil)|nil
---@field wheelmoved fun(self:System, dx:number, dy:number)|nil
---@field touchpressed fun(self:System, id:number, x:number, y:number, dx:number|nil, dy:number|nil, pressure:number|nil)|nil
---@field touchmoved fun(self:System, id:number, x:number, y:number, dx:number|nil, dy:number|nil, pressure:number|nil)|nil
---@field touchreleased fun(self:System, id:number, x:number, y:number, dx:number|nil, dy:number|nil, pressure:number|nil)|nil

--- Scene 可选回调接口
---@class SceneCallbacks
---@field enter fun(self:Scene, params:table|nil)|nil
---@field leave fun(self:Scene)|nil
---@field update fun(self:Scene, dt:number)|nil
---@field draw fun(self:Scene)|nil
---@field keypressed fun(self:Scene, key:string, scancode:string|nil, isrepeat:boolean|nil)|nil
---@field keyreleased fun(self:Scene, key:string, scancode:string|nil)|nil
---@field textinput fun(self:Scene, text:string)|nil
---@field mousepressed fun(self:Scene, x:number, y:number, button:integer, istouch:boolean|nil, presses:integer|nil)|nil
---@field mousereleased fun(self:Scene, x:number, y:number, button:integer, istouch:boolean|nil, presses:integer|nil)|nil
---@field mousemoved fun(self:Scene, x:number, y:number, dx:number, dy:number, istouch:boolean|nil)|nil
---@field wheelmoved fun(self:Scene, dx:number, dy:number)|nil
---@field touchpressed fun(self:Scene, id:number, x:number, y:number, dx:number|nil, dy:number|nil, pressure:number|nil)|nil
---@field touchmoved fun(self:Scene, id:number, x:number, y:number, dx:number|nil, dy:number|nil, pressure:number|nil)|nil
---@field touchreleased fun(self:Scene, id:number, x:number, y:number, dx:number|nil, dy:number|nil, pressure:number|nil)|nil

local Types = {}
return Types
