# AI Coding Agent Instructions (Love2D Idle Framework)

This repository is a Lua/LÖVE 2D "idle/text" game framework. Focus on these project-specific patterns and workflows to be immediately productive.

## Architecture Overview
- App aggregation: See [Engine/App.lua](../Engine/App.lua). `App` owns `EventBus`, `Timer`, `Storage`, `SceneManager`, `Style`, and a list of `System`s; forwards Love input events to systems and the current scene.
- Scenes: See [Engine/Scene.lua](../Engine/Scene.lua) and [Engine/SceneManager.lua](../Engine/SceneManager.lua). Create scenes via `Scene:extend()`, register with `app.scenes:register(name, scene)`, switch using `app:switchScene(name)`.
- Systems: See [Engine/System.lua](../Engine/System.lua). Extend `System` and attach via `app:addSystem(sys)`. Systems may implement `init/update/draw` and input handlers; they run every frame before the current scene.
- Input: See [Engine/Input.lua](../Engine/Input.lua). Centralizes keyboard/mouse states, emits `input:*` events (e.g. `input:keypressed`), and resets one-frame states in `update()`.
- Platform: See [Engine/Platform.lua](../Engine/Platform.lua). Detects OS, exposes DPI scale and common paths, clipboard and URL helpers; emits `platform:ready` on init.
- UI tree: See [Engine/Node.lua](../Engine/Node.lua) and UI components under [Engine/UI](../Engine/UI). Nodes form a tree; `update/draw/input` propagate to children; `Style:applyTree(root)` applies theme.
- Game layer: Example implementations in [Game/Scenes/MainScene.lua](../Game/Scenes/MainScene.lua), [Game/Systems/ResourceSystem.lua](../Game/Systems/ResourceSystem.lua), [Game/UI/TextPanel.lua](../Game/UI/TextPanel.lua).

## Developer Workflow
- Run (Windows):
  - `love .`
  - Or: `"C:\\Program Files\\LOVE\\love.exe" "d:\\Backup\\Documents\\git\\love2d"`
- Entry point: [main.lua](../main.lua) wires Love callbacks to the `App` (via [Engine/Bootstrap.lua](../Engine/Bootstrap.lua)). A custom `love.run` stabilizes FPS using [Engine/Config.lua](../Engine/Config.lua#L1).
- Bootstrap: `Bootstrap.boot()` creates `App`, adds `Input` and `Platform` systems, registers [Game/Scenes/MainScene.lua](../Game/Scenes/MainScene.lua), then switches to it.
- Timer: Use [Engine/Timer.lua](../Engine/Timer.lua) for scheduling: `app.timer:after(sec, fn)` and `app.timer:every(sec, fn)`.
- Storage: `app:save(name, table)` / `app:load(name)` for simple saves (numeric/string/boolean/nested tables).

## Conventions & Patterns
- OOP: Base class utilities in [Engine/Object.lua](../Engine/Object.lua); use `Class:extend()` + `new()`; `is()` for runtime type checks. Classes also support `__call` sugar, so `Class(...)` equals `Class:new(...)`. Prefer `Class(...)` for consistency.
- Scene lifecycle: Implement `enter/leave/update/draw`. Clean up event listeners in `leave()` via `app:off(event, handler)`.
- Scene switching: The manager pauses the old scene target and resumes the new one in `SceneManager:switch()`. Ensure scene listeners use `target=self` to benefit from this.
- Event bus: Use `app:on(event, fn)`, `app:once(event, fn)`, `app:emit(event, ...)`. Common events: `input:keypressed`, `input:keyreleased`, `input:text`, `input:mousepressed`, `input:mousereleased`, `input:mousemoved`, `input:wheelmoved`.
- Event bus: Use `app:on(event, fn, opts?)`, `app:once(event, fn, opts?)`, `app:emit(event, ...)`, `app:off(event, fn)`. Listeners support `opts.priority` (higher runs first) and `opts.target` for group pause/resume/off via `app:pauseTarget(target)` / `app:resumeTarget(target)` / `app:offTarget(target)`. Returning `true` from a listener stops further propagation.
- Input querying: Prefer `input:pressed(key)` / `input:isDown(key)` and `input:mousePressed(button)` for per-frame checks (see [Engine/Input.lua](../Engine/Input.lua)).
- Update vs draw: Heavy computation goes in `update(dt)`; keep `draw()` lightweight. Nodes sort children by `z` in `draw()`; large trees should avoid per-frame resorting when possible.
- UI style: Apply theme via `app.style:applyTree(root)` or per-widget setters (see [Engine/UI/Style.lua](../Engine/UI/Style.lua) and [Engine/UI/Defaults.lua](../Engine/UI/Defaults.lua)).
- Configuration & enums: Centralize parameters in [Engine/Config.lua](../Engine/Config.lua) (e.g., `FPS`, UI spacing/padding) and constants in [Engine/Enums.lua](../Engine/Enums.lua).
 - Performance & pooling: Use [Engine/Pool.lua](../Engine/Pool.lua) to reuse short-lived objects. Example: `local Pool = require("Engine.Pool"); local pool = Pool:new({ factory=function() return {} end, reset=function(o) for k in pairs(o) do o[k]=nil end end, maxSize=128 })`; then `local obj = pool:acquire()` / `pool:release(obj)`.
 - Node lifecycle: `Node:add()` triggers child `onEnter()`, `Node:remove()` triggers `onExit()`. Input handlers can “swallow” events by returning `true` (e.g., `mousepressed`), stopping sibling propagation.
 - Object helpers: Use `obj:bindEvent(bus, event, fn, opts)` to auto-track bus subscriptions; call `obj:destroy()` or `obj:unbindEvents()` to clean up without manual `off` calls.
 - Platform utilities: On init, `Platform` emits `platform:ready` with `{ os, dpiScale, userDir, saveDir }`. Use for adapting UI scale or OS-specific behavior.

## Practical Examples
- Register and switch scenes: in [Engine/Bootstrap.lua](../Engine/Bootstrap.lua), `app.scenes:register("main", MainScene:new(app)); app:switchScene("main")`.
- Listen/cleanup events: [Game/Scenes/MainScene.lua](../Game/Scenes/MainScene.lua) uses `self._h_key = self.app:on("input:keypressed", fn)` and removes in `leave()` with `self.app:off("input:keypressed", self._h_key)`.
- Advanced listener usage: `self._h = self.app:on("input:keypressed", fn, { priority = 10, target = self })` and later `self.app.events:pauseTarget(self)` during modal UI; resumable via `resumeTarget(self)`.
- Periodic actions: `app.timer:every(2, function() app:emit("tick") end)`.
- Query input: `self.input:pressed("space")` or `self.input:mousePressed(1)`; for positions: `self.input:mousePosition()`.
 - React to platform: `self._h_platform = self.app:on("platform:ready", function(info) self.uiScale = info.dpiScale or 1 end, { target = self })`.

## File Layout Reference
- Framework: [Engine/*](../Engine) core modules (App, Scene, Systems, EventBus, Timer, Storage, Input, Node, UI components, Style, Config, Enums).
- Game-specific: [Game/Scenes](../Game/Scenes), [Game/Systems](../Game/Systems), [Game/UI](../Game/UI).
- Assets & data: [Assets](../Assets) (fonts/images), [Data](../Data) (saves), docs in [Docs](../Docs).

If any part of these instructions is unclear or missing (e.g., additional systems, UI components, or scene switching nuances), tell me what to refine and I’ll update this file accordingly.