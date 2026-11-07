# 可选界面风格

模板提供 `system`（系统材质）和 `looseleaf`（手绘纸张）。手绘样式从灵感晾台 1.4.0 的原生 SwiftUI 实现提取，视觉参考 Looseleaf。模板自带纸纹图片及 MIT 授权，不需要来源应用目录、额外下载、字体、React 或 shadcn/ui。

![模板手绘纸张预览](../docs/screenshots/looseleaf.png)

## 创建与切换

```sh
python3 '<skill-dir>/scripts/scaffold.py' '/absolute/path/NewApp' \
  --name '任务晾台' --bundle-id 'local.example.taskrail' --style looseleaf
```

`--style` 只设定新项目的初始风格。运行时可通过菜单栏「界面风格」，或挂卡工具栏「位置与显示」中的「界面风格」切换。`RailState.style` 将选择保存到调用方 UserDefaults 的 `rail.style`，重启恢复。没有已存选项或值无法识别时使用 `defaultStyle`，默认值为 `.system`。不修改业务数据、挂卡顺序、位置、尺寸或固定状态。

已有工程接入时，将 `RailStyle.swift`、`RailPaperTexture.swift`、`Resources/Paper` 与其余通用源文件一并复制；同时保留 Package.swift 的资源声明与打包脚本的资源 bundle 复制逻辑。直接创建状态：

```swift
let state = RailState(defaults: .standard, defaultStyle: .looseleaf)
```

## 官方 Notebook 配色与用途

配色依据 [Looseleaf 官方 Theming 页面](https://kevintngo.github.io/looseleaf/#/foundations/theming) 的 Notebook 默认主题，已于 2026-11-07 核对页面加载的主题配置与 CSS。颜色以配置值为准，不从叠加纹理、阴影后的截图重新取样。SwiftUI 模板保留原生组件及既有轮廓，映射颜色用途并使用自带的官方纸纹 PNG，不引入网页运行时或字体。

| 官方用途 | 官方变量 | 色值 | 模板映射 |
| --- | --- | --- | --- |
| 桌面背景 | `--ll-desk` | `#A8C8BB` | `RailPaper.backdrop`，晾台大面积背景 |
| 普通纸面 | `--ll-paper` | `#F8F5EE` | `RailPaper.sheet`，默认便签；`canvas` 为同色别名，用于窗口与夹子 |
| 纸面次级填充 | `--ll-paper-shade` | `#ECE6DA` | 按业务需要使用，不作为默认便签底色 |
| 菜单与浮层纸面 | `--ll-slip` | `#FBF8F1` | `RailPaper.slip`，自定义悬浮工具栏；原生菜单仍由 macOS 绘制 |
| 索引卡纸 | `--ll-card` | `#FBF6E9` | 仅在业务明确采用索引卡时使用 |
| 牛皮纸 | `--ll-kraft` | `#DCC8A3` | 仅在业务明确采用牛皮纸时使用 |
| 正文墨色 | `--ll-ink` | `#2A2420` | `RailPaper.ink`，主文字与既有手绘轮廓 |
| 次级文字 | `--ll-ink-muted` | `#4A433C` | `RailPaper.inkMuted`，示例卡片副标题 |
| 阴影色 | `--ll-shade` | `#3A2C1E` | `RailPaper.shadow`，保留模板偏移阴影形状 |
| 主操作强调色 | `--ll-marker` | `#DF6B3C` | `RailPaper.marker`，显式自定义主按钮纸面 |

默认便签使用普通纸面 `--ll-paper`，而不是 `--ll-card`：官网的 `--ll-card` 指索引卡纸张，组件 Card 的语义背景实际映射到 `--ll-paper`。`--ll-shade` 的原始配置为 RGB 三元组 `58 44 30`，上表转换为等价十六进制。

遵循 Refactoring UI 的既有设计系统优先原则及 §2.4、§5.6.1：将桌面、纸面、墨色、阴影与操作强调色分开，避免混用。此前试调的浅灰绿 `#DDE8E3` 与截图取样 `#F7F2EA` 不再作为本技能默认值。`sage` 保留为 `backdrop` 的兼容别名；新增主按钮使用 `marker`，不要将桌面色当作官方主操作强调色。

本次配色检查（2026-11-07）：

| 检查项 | 位置 | 规则 | 原状 | 调整 | 验证 |
| --- | --- | --- | --- | --- | --- |
| 配色来源与层级 | 手绘晾台与卡片 | 既有设计系统优先、§2.4、§5.6.1 | 使用近似纸色、自拟背景及偏绿墨色，阴影复用墨色 | 按 Notebook 配置分配独立用途 | 检查标准横向与迷你竖向预览 |

按 sRGB 公式计算，主墨色 `#2A2420` 与普通纸面 `#F8F5EE` 的对比度为 14.06:1；与桌面背景 `#A8C8BB` 的对比度为 8.49:1。次级文字 `#4A433C` 与纸面的对比度为 8.93:1。这些数值仅验证所列文字组合，不代表所有业务卡片文字已通过对比度检查。

### 浅彩便签覆盖

按用户 2026-11-07 的偏好，绿、蓝、粉红纸面从官方色生成更浅的 200 阶，避免大面积彩色填充过重。保持原色相和 HSL 饱和度，提升明度；生成参数为 `generate_palette.py --base '<官方色>' --cap 0 --strength 0`，取输出的 200 阶。以下是本技能的定制覆盖，不是官方默认值；米白、桌面、文字、阴影及纸纹透明度保持原配置。

| 纸色 | 官方原色 | 本技能浅色 |
| --- | --- | --- |
| 绿色 | `#CFE6A8` | `#ECF5DD` |
| 蓝色 | `#BCD8F0` | `#E2EEF8` |
| 粉红色 | `#F6B8B0` | `#FBE1DE` |

## 纸面与内容

- `RailPaperShape` 使用固定曲线生成略不规则的轮廓。不要在 `body` 或绘制中加入随机数，否则输入、布局或状态刷新时边框会变化。
- `RailPaperSurface` 提供 1.6 点深色描边、向右 3 点／向下 4 点的实色偏移阴影，默认 `colorIndex: nil` 使用暖米白纸面。保留 0～3 对应黄 `#F7E38A`、浅绿 `#ECF5DD`、浅蓝 `#E2EEF8`、浅粉 `#FBE1DE`，供已有产品或用户明确要求彩色便签时使用；显式索引越界会限制在有效范围。
- `ClotheslineView` 已注入样式环境；卡片、工具栏、背景与夹子响应风格切换。默认省略 `paperColor` 即为统一暖米白便签。仅在明确需要彩色便签时，通过该闭包选择颜色：

```swift
ClotheslineView(state: state, items: items, title: { $0.title },
                paperColor: { $0.colorIndex }) { item, compact in
    MyCard(item: item, compact: compact)
}
```

`MyCard` 负责内容及交互，外层 `HangingCard` 负责纸面。不要再给内容铺满不透明背景，否则会遮住纸张颜色。`paperColor` 省略或返回 `nil` 时为暖米白色；系统材质忽略此索引。不要根据排序下标选颜色，避免重新排序后颜色发生变化。

## 纸张纹理

纯色填充不能替代纸张材质。`RailPaperTexture` 使用 Looseleaf 的原始透明 PNG，在底色上按 cloud → relief（或 slip）→ fibre 顺序绘制；这对应官网 CSS 从前往后的 fibre → relief/slip → cloud。保留原始透明度，不额外乘暗色或把纸纹盖在文字上。纸面背景与正文的层次按 Refactoring UI §7.2 保持独立。

- 普通便签：cloud 以 720 × 720 点平铺，relief 为 192 × 192 点，fibre 为 240 × 240 点。
- 悬浮工具栏：用 128 × 128 点的 slip 替换 relief，保持细纸纹；通过 `RailPaperSurface(stock: .slip)` 指定。
- 纹理裁切到 `RailPaperShape`，固定平铺原点，解码结果缓存；不随布局刷新重新生成随机噪点，不把整张纹理拉伸到卡片尺寸。
- 纹理位于内容后方，关闭命中测试及辅助功能，避免阻挡点击或增加朗读项。系统材质分支不绘制纸纹。
- SwiftPM 声明 `.copy("Resources/Paper")`；打包时将资源 bundle 放入 `.app/Contents/Resources`。加载优先查找安装包内资源，再回退到开发环境的 `Bundle.module`。接入其他 target 时调整 bundle 名称与资源入口。
- 保留 `THIRD_PARTY_LICENSES.txt` 中的 Looseleaf MIT 授权。纹理来源与固定版本见 [provenance.md](provenance.md)。

检查真实组件在标准横向及迷你竖向下的纸纹、接缝、文字清晰度和边缘裁切；另从打包应用生成预览，确认脱离 `.build` 后资源仍能加载。纯色对比度数值不等于所有纹理像素组合的对比度结论。

## 独立窗口与外观边界

`RailAppearance(state:windowBackground:)` 观察同一份 `RailState`，供已打开的详情、编辑器等窗口复用。控制器的 `showDetail` 已接入；自建窗口可以使用：

```swift
EditorView(model: model)
    .modifier(RailAppearance(state: state, windowBackground: true))
```

该 modifier 更新环境与背景，不替换内容根节点，也不使用 `.id(style)`。这样风格切换不会因重建根节点而清空 `@State` 或编辑器内容。手绘主题显式采用浅色 SwiftUI 环境，系统材质仍跟随系统。系统标题栏与原生菜单保持 macOS 外观；嵌入的自定义 AppKit 编辑器需要宿主同时更新文字与背景，不能假定 SwiftUI 环境会自动修改其所有属性。

需要给业务主按钮添加强调纸面时，在按钮标签的 padding 后加 `.modifier(RailPaperSurface(fill: RailPaper.marker))`，配合 `.buttonStyle(.plain)`。点击、禁用、焦点和辅助功能语义仍由实际 Button 提供。

## 验证

运行模板测试和打包，再用 `--preview-directory` 生成 32 张预览；文件名包含风格、边缘、尺寸和系统外观。手绘风格的 dark 预览表示“系统处于深色时仍显示浅色纸张”，并非暗色纸张主题。检查四边夹子方向、阴影留白、滚动区域和工具栏。另手动验证菜单切换、编辑中切换与重启恢复，截图不能代替交互验证。
