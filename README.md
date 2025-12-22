# Love2D 文本放置类框架（基础）

本仓库提供用于开发 2D 文字放置类游戏的基础 OOP 框架模块：

- Engine/Object.lua：简单 OOP（new/extend/is），支持 `__call` 实例化糖（`Class(...)` 等价于 `Class:new(...)`）
- Engine/System.lua：系统基类（init/update/draw/reset）
- Engine/EventBus.lua：事件总线（on/off/emit/once）
- Engine/Timer.lua：计时与调度（after/every/update/cancel）
- Engine/Scene.lua：场景基类（enter/leave/update/draw）
- Engine/SceneManager.lua：场景管理器（register/switch/update/draw）
- Engine/Storage.lua：简易存档（save/load）
- Engine/App.lua：应用总控（聚合事件/计时/场景/系统）
 - Engine/Node.lua：节点基类（位置/缩放/旋转、子节点与绘制传递）
 - Engine/UI/Label.lua：文本标签
 - Engine/UI/Panel.lua：面板背景与边框容器
 - Engine/UI/Button.lua：可点击按钮（支持 hover/pressed/disabled）
 - Engine/UI/TextInput.lua：文本输入框（点击聚焦、键盘输入）
 - Engine/UI/ListView.lua：简单列表视图（选择项回调）
 - Engine/Input.lua：输入系统（键盘/鼠标状态查询与事件聚合）
 - Engine/Trigger.lua：触发系统（条件/阈值触发、一次性/冷却、事件广播）
 - Engine/UI/Layout.lua：布局容器（垂直/水平堆叠、间距、内边距、对齐）
 - Engine/UI/Style.lua：主题与样式（统一控件配色与风格）
 - Engine/UI/Defaults.lua：UI 默认样式集中定义
 - Engine/Config.lua：项目配置（如 FPS、默认 UI 间距/内边距）
 - Engine/Enums.lua：枚举集中管理（按钮状态/布局方向与对齐/鼠标键）

## 项目结构

```
Assets/
    fonts/        字体资源
    images/       图片资源
Data/           存档与数据输出
Docs/           文档与设计记录
Engine/         核心框架模块
Game/
    Scenes/       具体场景脚本
    Systems/      游戏系统（如资源系统）
    UI/           简易文本 UI
```

## 日志输出与运行

- 日志：框架内置 `Logger` 系统，日志文件每日写入项目根目录的 `Logs/` 目录，例如 `Logs/game-YYYY-MM-DD.log`。
- 运行：在安装了 LÖVE 的环境中，进入项目目录运行 `love .` 即可；Windows 可直接执行 `love.exe` 指向项目路径。

## 快速集成

示例将这些模块与 Love2D 的主循环连接：
- UI naming conventions: see [Docs/UI-Naming.md](Docs/UI-Naming.md).

```lua
local App = require("Engine.App")
local Scene = require("Engine.Scene")

local app

function love.load()
    app = App()

    -- 定义一个简单场景
    local Main = Scene:extend()
    function Main:enter()
        self.t = 0
        app:on("tick", function() print("tick") end)
        app.timer:every(1, function() app:emit("tick") end)
    end
    function Main:update(dt)
        self.t = self.t + dt
    end
    function Main:draw()
        love.graphics.print("Hello Idle! " .. tostring(math.floor(self.t)), 20, 20)
    end

    -- 注册并切换到该场景
    app.scenes:register("main", Main(app))
    app:switchScene("main")
end

function love.update(dt)
    app:update(dt)
end

function love.draw()
    app:draw()
end
```

将上述片段合并到你的 `main.lua` 即可运行（或参考后续示例自定义）。

### OOP 实例化约定（__call 语法）

框架为所有由 `Object:extend()` 创建的类提供 `__call` 语法糖：

```lua
local Object = require("Engine.Core.Object")
local MyClass = Object:extend()

function MyClass:init(a, b)
    self.a = a; self.b = b
end

-- 等价的两种实例化方式：
local x = MyClass(1, 2)  -- 推荐：更简洁统一
local y = MyClass(1, 2)
```

建议项目统一采用 `Class(...)` 的方式进行实例化，以提升可读性与一致性。

### 使用 Bootstrap 集成示例

若使用已经提供的示例场景/系统，可在 `main.lua` 中：

```lua
local Bootstrap = require("Engine.Bootstrap")
local app

function love.load()
    app = Bootstrap.boot()
end

function love.update(dt)
    app:update(dt)
end

function love.draw()
    app:draw()
end

function love.keypressed(key, scancode, isrepeat)
    app:keypressed(key, scancode, isrepeat)
end

function love.textinput(text)
    app:textinput(text)
end

function love.keyreleased(key, scancode)
    app:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, presses)
    app:mousepressed(x, y, button, presses)
end

function love.mousereleased(x, y, button, presses)
    app:mousereleased(x, y, button, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    app:mousemoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(dx, dy)
    app:wheelmoved(dx, dy)
end
```

## 存档使用

```lua
app:save("save1", { gold = 100, workers = { miner = 2 } })
local data = app:load("save1")
```

> 说明：序列化支持数字/字符串/布尔值与嵌套表；函数/用户数据等将被忽略为 `nil`。

## 下一步建议

- 添加资源系统（资源产出/消耗与速率）
- 命令输入/控制台组件（处理文字命令）
- 简易 UI 文本布局（面板/列表/提示）
 - 使用 Layout 容器组织 UI，并用 Style 统一主题
 - 通过 Defaults/Style 集中维护控件颜色与风格，减少硬编码
 - 通过 Config 统一管理运行参数（如帧率）
 - 使用 Enums 替代字符串/数字硬编码（例如按钮状态、鼠标键值、布局方向/对齐）
- 多存档与自动保存策略
- 事件驱动的升级/成就系统
 - 使用 Trigger 系统组织条件达成与奖励发放

## Trigger 用法示例

注册触发器（例如当 Gold ≥ 50 时发放一次奖励；若希望可重复，则设置 `once=false` 并加上 `cooldown`）：

```lua
local Trigger = require("Engine.Trigger")
local ResourceSystem = require("Game.Systems.ResourceSystem")

function love.load()
    app = require("Engine.Bootstrap").boot()

    -- 确保有资源系统
    local res = ResourceSystem()
    res:addResource("gold", { amount = 0, rate = 5, display = "Gold" })
    app:addSystem(res)

    local trg = Trigger()
    app:addSystem(trg)

    -- 使用阈值便捷添加：getter + 比较 + 值
    trg:addThreshold("gold_reward", function()
            local g = res:get("gold")
            return g and g.amount or 0
        end, ">=", 50,
        function(ctx)
            print("Trigger: gold ≥ 50, grant bonus!")
            local g = res:get("gold")
            if g then g.amount = g.amount + 10 end
        end,
        { once = true } -- 仅触发一次
    )

    -- 也可以使用通用条件函数
    trg:add("tick_every_2s", {
        condition = function(ctx) return true end, -- 无条件，靠冷却控制节奏
        action = function(ctx) app:emit("tick") end,
        once = false,
        cooldown = 2
    })
end
```

监听触发事件：

```lua
app:on("trigger:fired", function(name, item)
    print("Trigger fired:", name)
end)
```

## 运行

在已安装 Love2D 的环境下（Windows）：

```powershell
love .
# 或者指定 love.exe 路径，例如：
"C:\Program Files\LOVE\love.exe" "d:\Backup\Documents\git\love2d"

## 布局与风格示例

使用布局容器在面板中垂直排列控件，并应用统一主题：

```lua
local Layout = require("Engine.UI.Layout")
local Style = require("Engine.UI.Style")
local Panel = require("Engine.UI.Panel")
local Button = require("Engine.UI.Button")
local Label = require("Engine.UI.Label")
local TextInput = require("Engine.UI.TextInput")

function SomeScene:enter()
    self.root = require("Engine.Node")()

    -- 背景面板 + 布局容器
    local panel = Panel(20, 20, 300, 180, { fill = {0.12,0.12,0.12,0.9} })
    self.root:add(panel)
    local layout = Layout(26, 26, 288, 168, { direction = "vertical", spacing = 8, align = "start" })
    self.root:add(layout)

    -- 添加控件
    local title = Label("Demo UI", 0, 0)
    local input = TextInput(0, 0, 260, 28, { placeholder = "Type here..." })
    local btn = Button("Confirm", 0, 0, 120, 30, { onClick = function() print("Clicked!") end })
    layout:add(title)
    layout:add(input)
    layout:add(btn)

    -- 应用主题样式
    local style = Style() -- 可传入自定义 theme
    style:applyTree(self.root)
end

function SomeScene:update(dt) self.root:update(dt) end
function SomeScene:draw() self.root:draw() end
function SomeScene:keypressed(k,s,r) self.root:keypressed(k,s,r) end
function SomeScene:textinput(t) self.root:textinput(t) end
function SomeScene:mousepressed(x,y,b,p) self.root:mousepressed(x,y,b,p) end
function SomeScene:mousereleased(x,y,b,p) self.root:mousereleased(x,y,b,p) end
function SomeScene:mousemoved(x,y,dx,dy,t) self.root:mousemoved(x,y,dx,dy,t) end
```
```
