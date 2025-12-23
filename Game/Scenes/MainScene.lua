-- Game/Scenes/MainScene.lua
-- 示例主场景：资源增长 + 文本面板

local Scene = require("Engine.Core.Scene")
local ResourceSystem = require("Game.Systems.ResourceSystem")
local TextPanel = require("Game.UI.TextPanel")
local Panel = require("Engine.UI.Panel")
local Label = require("Engine.UI.Label")
local ListView = require("Engine.UI.ListView")
local Input = require("Engine.Systems.Input")
local Vector2 = require("Engine.Utils.Vector2")
local Behavior = require("Engine.AI.Behavior")
local Color = require("Engine.Utils.Color")

local MainScene = Scene:extend()

local function deepEqual(a, b, seen)
    if a == b then return true end
    local ta, tb = type(a), type(b)
    if ta ~= tb then return false end
    if ta ~= "table" then return a == b end
    seen = seen or {}
    if seen[a] and seen[a] == b then return true end
    seen[a] = b
    local k
    for k in pairs(a) do
        if not deepEqual(a[k], b[k], seen) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

function MainScene:enter()
    if self.app and self.app.logger then self.app.logger:info("MainScene enter") end
    -- 资源系统
    self.resources = ResourceSystem()
    self.resources:addResource("gold", { amount = 0, rate = 1, display = "Gold" })
    self.resources:addResource("wood", { amount = 10, rate = 0.5, display = "Wood" })
    self.app:addSystem(self.resources)

    -- 文本面板
    self.log = TextPanel(10, 140, 580)
    self.log:add("Press [Space] to log a message.")

    -- 示例 Panel：启用剪裁，内部子元素超出时不溢出（使用链式调用）
    self.demoPanel = Panel()
        :setPosition(400, 40)
        :setSize(160, 80)
        :setBorderWidth(2)
        :setFill(Color({0.15, 0.15, 0.18, 0.95}))
    for i = 1, 10 do
        local lbl = Label()
            :setText("Item " .. i)
            :setPosition(6, 6 + (i - 1) * 18)
            :setColor(0.9, 0.9, 1.0, 1.0)
        self.demoPanel:add(lbl)
    end

    -- Pivot + Vector2 示例：中心锚点的面板，使用向量设置位置（链式调用）
    self.pivotPanel = Panel()
        :setSize(100, 40)
        :setPivotCenter()
        :setPositionV(Vector2(300, 80))
        :setFill({0.2, 0.3, 0.4, 0.9})
        :setBorder({0.8, 0.9, 1.0, 1.0})

    -- 可滚动列表示例：与剪裁结合（使用链式调用）
    self.scrollList = ListView()
        :setPosition(400, 140)
        :setWidth(200)
        :setItemHeight(18)
        :setMaxVisible(6)
        :setColors({
            bg = {0.05, 0.05, 0.08, 1},
            border = {0.8, 0.8, 1.0, 0.9},
            text = {1, 1, 1, 1},
            hover = {0.2, 0.25, 0.3, 0.8},
            selected = {0.3, 0.5, 0.3, 0.8}
        })
    for i = 1, 30 do
        self.scrollList:add("Row " .. i)
    end

    -- 输入系统：优先使用 Bootstrap 提供的全局实例，避免重复
    if not self.input then
        if self.app and self.app.input then
            self.input = self.app.input
        else
            self.input = Input()
            self.app:addSystem(self.input)
            -- 同步为全局，便于其他场景/系统查询复用
            self.app.input = self.input
        end
    end

    -- 事件日志：键盘/鼠标
    self._h_key = self.app:on("input:keypressed", function(key)
        self.log:add("[key] " .. tostring(key))
        if self.app and self.app.logger then self.app.logger:debugf("keypressed: %s", tostring(key)) end
    end)
    self._h_text = self.app:on("input:text", function(t)
        self.log:add("[text] " .. tostring(t))
    end)
    self._h_mpress = self.app:on("input:mousepressed", function(x, y, button)
        self.log:add(string.format("[mouse] btn%d at (%.0f,%.0f)", button, x, y))
        if self.app and self.app.logger then self.app.logger:debugf("mousepressed: btn%d (%.0f,%.0f)", button, x, y) end
        if self.scrollList and self.scrollList.mousepressed and self.scrollList:hitTest(x, y) then
            self.scrollList:mousepressed(x, y, button)
        end
    end)
    -- 鼠标移动：转发到列表用于拖拽
    self._h_mmove = self.app:on("input:mousemoved", function(x, y, dx, dy)
        if self.scrollList and self.scrollList.mousemoved then
            self.scrollList:mousemoved(x, y)
        end
    end)

    -- 鼠标释放：结束拖拽/选择
    self._h_mrelease = self.app:on("input:mousereleased", function(x, y, button)
        if self.scrollList and self.scrollList.mousereleased then
            self.scrollList:mousereleased(x, y, button)
        end
    end)

    -- 鼠标滚轮：在列表区域内滚动
    self._h_wheel = self.app:on("input:wheelmoved", function(dx, dy)
        if self.input and self.scrollList and self.scrollList.hitTest then
            local mx, my = self.input:mousePosition()
            if self.scrollList:hitTest(mx, my) then
                self.scrollList:wheelmoved(dx, dy)
            end
        end
    end)

    -- 每 2 秒打印一次 tick
    self.app.timer:every(2, function()
        self.log:add("Tick at " .. tostring(os.time()))
    end)

    self.log:add("Press [F3] to run storage tests (Lua/JSON).")
    self.log:add("Press [F4] to load Data JSON (sample_*).")
    self.log:add("Press [F6] to switch to ChainTestScene.")
    self.log:add("Press [F7] to test Color utility class.")
    self.log:add("Press [F8] to test Behavior Tree.")
    self.log:add("Press [F9] to test Effect Tree.")
end

function MainScene:update(dt)
    -- 查询式输入示例（本帧触发）
    if self.input and self.input:pressed("space") then
        self.log:add("[pressed] space")
    end
    if self.input and self.input:mousePressed(1) then
        local mx, my = self.input:mousePosition()
        self.log:add(string.format("[pressed] mouse1 at (%.0f,%.0f)", mx, my))
    end
end

function MainScene:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Main Scene", 10, 10)
    self.log:draw()
    -- 绘制示例剪裁面板
    if self.demoPanel and self.demoPanel.draw then
        self.demoPanel:draw()
    end
    -- 绘制中心锚点面板
    if self.pivotPanel and self.pivotPanel.draw then
        self.pivotPanel:draw()
    end
    -- 绘制可滚动列表
    if self.scrollList and self.scrollList.draw then
        self.scrollList:draw()
    end
end

function MainScene:keypressed(key)
    if key == "f2" then
        if self.app and self.app.logger then self.app.logger:info("Switch to button-test scene") end
        if self.app and self.app.switchScene then self.app:switchScene("button-test") end
        return
    end
    if key == "f5" then
        if self.app and self.app.logger then self.app.logger:info("Switch to vec-anim-test scene") end
        if self.app and self.app.scenes then
            -- 懒注册：仅首次按下时注册
            if not self._vecTestRegistered then
                local ok, SceneMod = pcall(require, "Game.Scenes.VecAnimTestScene")
                if ok and SceneMod then
                    self.app.scenes:register("vec-anim-test", SceneMod(self.app))
                    self._vecTestRegistered = true
                else
                    if self.app and self.app.logger then self.app.logger:error("VecAnimTestScene require failed") end
                    return
                end
            end
            self.app:switchScene("vec-anim-test")
        end
        return
    end
    if key == "f6" then
        if self.app and self.app.logger then self.app.logger:info("Switch to chain-test scene") end
        if self.app and self.app.scenes then
            -- 懒注册：仅首次按下时注册
            if not self._chainTestRegistered then
                local ok, SceneMod = pcall(require, "Game.Scenes.ChainTestScene")
                if ok and SceneMod then
                    self.app.scenes:register("chain-test", SceneMod(self.app))
                    self._chainTestRegistered = true
                else
                    if self.app and self.app.logger then self.app.logger:error("ChainTestScene require failed") end
                    return
                end
            end
            self.app:switchScene("chain-test")
        end
        return
    end
    if key == "f7" then
        if self.app and self.app.logger then self.app.logger:info("Switch to color-test scene") end
        if self.app and self.app.scenes then
            -- 懒注册：仅首次按下时注册
            if not self._colorTestRegistered then
                local ok, SceneMod = pcall(require, "Game.Scenes.ColorTestScene")
                if ok and SceneMod then
                    self.app.scenes:register("color-test", SceneMod(self.app))
                    self._colorTestRegistered = true
                else
                    if self.app and self.app.logger then self.app.logger:error("ColorTestScene require failed") end
                    return
                end
            end
            self.app:switchScene("color-test")
        end
        return
    end
    if key == "f8" then
        if self.app and self.app.logger then self.app.logger:info("Run behavior tree demo") end
        self:runBehaviorDemo()
        return
    end
    if key == "f9" then
        if self.app and self.app.logger then self.app.logger:info("Switch to effect-test scene") end
        if self.app and self.app.scenes then
            if not self._effectTestRegistered then
                local ok, SceneMod = pcall(require, "Game.Scenes.EffectTestScene")
                if ok and SceneMod then
                    self.app.scenes:register("effect-test", SceneMod(self.app))
                    self._effectTestRegistered = true
                else
                    if self.app and self.app.logger then self.app.logger:error("EffectTestScene require failed") end
                    return
                end
            end
            self.app:switchScene("effect-test")
        end
        return
    end
    if key == "f3" then
        if self.app and self.app.logger then self.app.logger:info("Run storage tests") end
        self:runStorageTests()
        return
    end
    if key == "f4" then
        if self.app and self.app.logger then self.app.logger:info("Run Data JSON read tests") end
        self:runDataJsonTests()
        return
    end
    if key == "space" then
        self.log:add("Space pressed: +5 gold")
        if self.app and self.app.logger then self.app.logger:info("Space adds 5 gold") end
        local g = self.resources:get("gold")
        if g then g.amount = g.amount + 5 end
    end
end

function MainScene:runStorageTests()
    local storage = self.app and self.app.storage
    if not storage then
        self.log:add("[test] storage not available")
        return
    end
    local sample = { a = 1, s = "hi", nested = { x = 3 }, arr = {1,2,3}, flag = true }
    -- JSON
    local ok1, err1 = storage:saveData("test_json", sample, { format = "json", pretty = true })
    local jdata, jerr = storage:loadData("test_json", { format = "json" })
    local passJ = ok1 and jdata and deepEqual(sample, jdata)
    local msgJ = passJ and "PASS" or ("FAIL: " .. tostring(err1 or jerr))
    self.log:add("[test][json] " .. msgJ)
    if self.app and self.app.logger then self.app.logger:info("[test][json] " .. msgJ) end

    -- Lua
    local ok2, err2 = storage:saveData("test_lua", sample, { format = "lua" })
    local ldata = storage:loadData("test_lua", { format = "lua" })
    local passL = ok2 and ldata and deepEqual(sample, ldata)
    local msgL = passL and "PASS" or ("FAIL: " .. tostring(err2))
    self.log:add("[test][lua] " .. msgL)
    if self.app and self.app.logger then self.app.logger:info("[test][lua] " .. msgL) end
end

function MainScene:runDataJsonTests()
    local storage = self.app and self.app.storage
    if not storage then
        self.log:add("[data] storage not available")
        return
    end
    -- 从 Data 目录读取示例 JSON
    local items, ierr = storage:loadData("Data/sample_items", { format = "json" })
    if items and type(items) == "table" then
        local count = #items
        self.log:add(string.format("[data][items] loaded %d items", count))
        if self.app and self.app.logger then self.app.logger:infof("[data][items] %d loaded", count) end
    else
        self.log:add("[data][items] FAIL: " .. tostring(ierr))
        if self.app and self.app.logger then self.app.logger:errorf("[data][items] %s", tostring(ierr)) end
    end

    local cfg, cerr = storage:loadData("Data/sample_config", { format = "json" })
    if cfg and type(cfg) == "table" and cfg.ui and cfg.resources then
        self.log:add("[data][config] PASS: has ui/resources")
        if self.app and self.app.logger then self.app.logger:info("[data][config] PASS") end
    else
        self.log:add("[data][config] FAIL: " .. tostring(cerr))
        if self.app and self.app.logger then self.app.logger:errorf("[data][config] %s", tostring(cerr)) end
    end
end

function MainScene:runBehaviorDemo()
    local Status = Behavior.Status

    -- 等待动作：运行给定秒数后成功
    local WaitAction = Behavior.Node:extend()
    function WaitAction:init(opts)
        Behavior.Node.init(self, opts)
        self.duration = (opts and opts.duration) or 1.0
        self.elapsed = 0
    end
    function WaitAction:start(bb)
        self.elapsed = 0
    end
    function WaitAction:update(dt, bb)
        self.elapsed = self.elapsed + (dt or 0)
        if self.elapsed >= self.duration then
            return Status.Success
        else
            return Status.Running
        end
    end

    -- 立即成功动作
    local InstantSuccess = Behavior.Node:extend()
    function InstantSuccess:update(dt, bb)
        return Status.Success
    end

    -- 行为树：Sequence(Wait 1.0s, InstantSuccess)
    local seq = Behavior.Sequence({
        children = {
            WaitAction({ name = "wait1s", duration = 1.0 }),
            InstantSuccess({ name = "done" })
        }
    })
    local tree = Behavior.Tree(seq, { demo = true })

    self.log:add("[bt] demo start: Sequence(wait, instant)")
    local step = 0.2
    local id
    id = self.app.timer:every(step, function()
        local s = tree:tick(step)
        self.log:add(string.format("[bt] tick -> %s", tostring(s)))
        if s ~= Status.Running then
            self.log:add(string.format("[bt] demo end: %s", tostring(s)))
            self.app.timer:cancel(id)
        end
    end)
end

function MainScene:leave()
    if self.app and self.app.logger then self.app.logger:info("MainScene leave") end
    -- 清理事件监听器
    if self._h_key then self.app:off("input:keypressed", self._h_key) end
    if self._h_text then self.app:off("input:text", self._h_text) end
    if self._h_mpress then self.app:off("input:mousepressed", self._h_mpress) end
    if self._h_wheel then self.app:off("input:wheelmoved", self._h_wheel) end
    if self._h_mmove then self.app:off("input:mousemoved", self._h_mmove) end
    if self._h_mrelease then self.app:off("input:mousereleased", self._h_mrelease) end
end

return MainScene
