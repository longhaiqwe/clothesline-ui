---
name: clothesline-ui
description: 使用 SwiftUI＋AppKit 构建或改造 macOS 屏幕边缘晾衣杆、挂卡、悬停展开界面。提供可运行模板、通用挂卡组件、四边吸附、固定、排序与菜单栏入口。适用于用户明确要求晾衣杆式呈现，或已有此类原生界面的复用；普通仪表盘和网页布局不默认采用此模式。
---

# Clothesline UI · 晾衣杆界面

把独立、简短、经常查看或取用的内容挂在屏幕边缘。首版支持 macOS 14+、SwiftUI＋AppKit、Swift Package Manager，无第三方运行时依赖。

## 开始工作

先确定卡片承载的业务对象、最重要的信息和主要操作。根据现有需求直接推进；只在缺失信息会改变实现时询问。少量状态、内容摘录、临时文件和快捷操作适合挂卡；长文编辑和复杂管理放到详情窗口。

- **新应用**：执行下方脚手架命令，再读 [references/integration.md](references/integration.md) 接入业务数据。
- **已有 SwiftUI＋AppKit 应用**：先读 integration.md 的“接入已有工程”，只移植所需组件，不覆盖入口、业务模型或用户配置。
- **修改布局、窗口或交互**：读 [references/interaction.md](references/interaction.md)，保留已经验证的坐标、悬停和窗口层级约束。
- **来源与验证范围**：见 [references/provenance.md](references/provenance.md)。模板只依赖本技能自带文件，不依赖来源项目路径。

将 `<skill-dir>` 替换为当前 SKILL.md 所在目录。目标目录必须不存在：

```sh
python3 '<skill-dir>/scripts/scaffold.py' '/absolute/path/NewApp' \
  --name '任务晾台' --bundle-id 'local.example.taskrail' --symbol 'checklist'
cd '/absolute/path/NewApp'
swift test
python3 scripts/build_app.py
```

脚本只生成新目录；构建脚本在该项目的 `dist/` 下生成本地 ad-hoc 签名应用，不自动安装或启动。Swift target 与二进制名称固定为 `ClotheslineApp`，产品显示名和 bundle ID 可配置。

## 接入业务

1. 用稳定 UUID 的业务对象替换 `DemoItem`；不要在每次刷新时重新生成身份。
2. 用自己的 SwiftUI 卡片替换 `DemoCard`，通过 `ClotheslineView(state:items:title:card:)` 注入。业务服务、权限、存储和网络请求属于产品层。
3. 产品需要文件拖入时，在 `RailWindowController` 传入 `onFileDrop` 回调，模板会启用原生文件 URL 接收和拖动文件时的边缘展开。读取 `state.isDropTarget` 展示接收提示；复制、去重、持久化和文件权限由产品实现。需要文件拖出时，使用真实 NSURL pasteboard writer 与复制语义，详见 integration.md。
4. 在 `RailMetrics` 中选择两套可读的卡片尺寸；标准与迷你可以改变信息密度。溢出沿绳子方向滚动，不靠缩小文字塞满屏幕。
5. 设置产品名、唯一 bundle ID 和表达产品用途的菜单栏图标。绳子与夹子是展开界面的语言，不要求图标也画晾衣杆。模板图标是占位符。
6. 根据需求补齐详情、空状态、加载／失败／过期状态、真实操作。示例进度与清单仅演示视图，不能当成已实现的下载、任务或持久化功能。

通用组件按源文件提供，不是单独发布的 Swift library。优先直接复用已有组件，按产品需求改变尺寸、材质、装饰或分组。模板默认逐卡排序；需要按组移动时，由业务层提供组模型与组视图，保留组内独立卡片。

## 保留的交互约定

- 贴近选定物理屏幕边缘约 0.3 秒展开，离开约 0.55 秒收起；菜单操作、按住鼠标和拖动期间不自动收起。
- 固定展开与锁定位置独立；用户明确收起时解除固定。系统菜单提供非拖拽的位置切换。
- 拖动绳子或移动手柄改变位置，松手吸附最近边缘；拖动夹子调整顺序，避免抢占卡片内部按钮和滚动。
- 每张卡提供 VoiceOver“前移／后移”；减少动态效果时停用摆动和排序弹簧，减少透明度时使用实色。
- 图标使用 macOS template image 自动适配颜色；界面默认跟随系统外观。产品可明确选择纸张主题，但应同时确定文字与对比度。
- 打开详情不能被高层级挂卡遮住。模板采用“收起挂卡并解除固定后打开详情”；如产品需要保留固定，按 interaction.md 调整详情层级。

## 验证与交付

运行 `swift test` 和 `python3 scripts/build_app.py`。纯代码通过还不代表交互完成：

```sh
swift run ClotheslineApp --preview-directory /absolute/path/previews
```

这个命令渲染真实组件的四边 × 标准／迷你 × 深浅色共 16 张 PNG，使用隔离偏好、不启动常驻菜单栏程序。检查内容、夹子、操作栏和滚动区域是否裁切。手动验证悬停、固定、菜单、拖动、详情和重启；修改多屏行为时验证跨屏与断屏回退。区分已运行检查和未覆盖场景，不将截图验证描述为完整实机验证。

保留模板的 `THIRD_PARTY_LICENSES.txt`，不要在移植装饰代码时丢失原始授权。

交付业务界面、可运行工程和简短验证结论。只有用户要求安装或替换应用时才执行对应部署；不要顺带迁移来源应用或覆盖其偏好。
