# UI 命名与约定（标准化设计）

本规范统一 UI 组件的属性/方法/事件/主题键命名，用于保持一致性、可读性与可维护性。新组件与改造应遵循本规范；旧接口允许通过兼容别名过渡。

## 核心数据命名
- 位置与尺寸：
  - 位置：`x`, `y`（像素）
  - 尺寸：`w`, `h`（像素）
  - 缩放：`sx`, `sy`
  - 方法：`setPosition(x, y)`, `setSize(w, h)`, `setScale(sx, sy)`（均返回 `self`）
- 可见/可用：
  - `visible: boolean`, `enabled: boolean`
  - 方法：`setVisible(v)`, `setEnabled(v)`（返回 `self`）
- 命中：
  - 方法：`hitTest(mx, my)`（世界坐标，返回 boolean）

## 颜色与主题键
- 颜色使用 0..1 RGBA 数组：`{r,g,b,a}`
- 组件颜色字段：
  - 文本：`color`
  - 背景：`bg`（推荐），历史别名：`fill`（逐步淘汰）
  - 边框：`border`，宽度：`borderWidth`
- 主题（Style.theme）键：
  - `panel.bg`, `panel.border`, `panel.borderWidth`
  - `text.color`
  - `button.{normal, hover, pressed, disabled, border, text, focus}`
  - `input.{bg, border, text, placeholder}`
  - `list.{bg, border, text, hover, selected}`
  - `layout.{bg?, border, borderWidth}`
  - `progress.{bg?, fill, border}`
- Style 应提供 `applyXxx(widget)` 并在 `applyTree()` 中识别并应用（已覆盖 Button/Panel/Label/TextInput/ListView/Layout/ProgressBar）。

## 容器与布局
- `Layout`：
  - 方向：`direction`（`vertical|horizontal`，见 `Enums.LayoutDirection`）
  - 双轴间距：`spacing`（统一默认间距），细分：`gapX`, `gapY`
  - 内边距：`padding: number | {l,t,r,b}`；内部展开为 `padL/padT/padR/padB`
  - 对齐：`align`（交叉轴），`justify`（主轴：`start|center|end|space-between`）
  - 行为：`wrap`, `clip`, `autoSize`
  - 常用方法：`setDirection/setSpacing/setPadding/setAlign/setJustify/setWrap/setClip/setGaps/setAutoSize/setSize/add/remove`（全部返回 `self`）

## 列表与输入
- `ListView`：
  - 数据：`items: string[]`, `selected?: integer`, `onSelect(self, index, value)`
  - 视图：`itemHeight`, `maxVisible`, `padding`, `colors`
  - 滚动：`scrollY`（像素），方法：`setScroll(y)`, `scrollBy(dy)`（返回 `self`）
  - 尺寸查询：`getHeight/getViewportHeight/getContentHeight/getScrollMax`
- `TextInput`：
  - 字段：`text`, `caret`, `focused`, `placeholder`, `colors`
  - 方法：`setText(text) -> self`, `getText()`；键鼠事件遵循 Love 回调名

## 按钮与进度
- `Button`：
  - 状态：`state`（见 `Enums.ButtonState`），`focused`, `disabled`
  - 回调：`onClick(self)`
  - 方法：`setDisabled(d) -> self`, `setFocus(f) -> self`
  - 颜色：`colors`（主题键如上）
- `ProgressBar`：
  - 值域：`min=0, max=1, value`；方法：`setRange(min,max) -> self`, `setValue(v) -> self`
  - 颜色：`colors.{bg?, fill, border}`；边框：`borderWidth`

## 事件命名
- Love 事件直通：`mousepressed/mousereleased/mousemoved/wheelmoved/keypressed/keyreleased/textinput`
- 自定义事件回调统一 `onXxx` 命名（如 `onClick`、`onSelect`）。
- App 事件总线命名：`domain:event`（示例：`input:keypressed`, `loading:progress`）。

## 链式调用
- 所有 setter 与改变状态的方法返回 `self`（已实现：`Node/Widget/Layout/Label/Panel/ListView/TextInput/Button/ProgressBar`）。
- 例：
  ```lua
  Layout(40, 40, 320, 200)
    :setPadding(10)
    :setSpacing(8)
    :add(Button("OK", 0,0,120,32):setFocus(true))
    :add(ProgressBar(0,0,200,12):setValue(0.5))
  ```

## 兼容与迁移
- 别名与过渡：
  - `bg` 是推荐字段；`fill` 为历史别名。组件应接受 `opts.bg` 并映射到内部实现（Panel 已支持）。
- 变更策略：
  - 在下一个次要版本中继续保留别名与旧字段；随后在主要版本中移除并在 CHANGELOG 中声明。

## 代码风格
- 方法名使用小驼峰：`setSize`, `mousepressed`（Love API 保持原样）。
- 枚举使用 `Enums` 集中定义，不散落字符串/数字字面量。
- 单字母缩写仅用于通用几何：`x/y/w/h/sx/sy`。
