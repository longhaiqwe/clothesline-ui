# 来源与验证范围

此技能首版于 2026-10-23 从用户自己的「AI 用量看板」项目提取，并将业务依赖替换为泛型 SwiftUI 内容。实际抽取入口是 AI 用量看板。该项目的原始第三方说明注明，绳子、夹子、材质、固定与动效改编自 IdeaLine 1.3.0，IdeaLine 又致谢 Tendedero（Alejandro Buján）。模板保留 [原始 MIT 授权及来源](../assets/swiftui-appkit/THIRD_PARTY_LICENSES.txt)，打包时一并放入应用资源。未从 PinSnip 提取代码或素材。

## 提取映射

| 来源文件 | 模板处理 |
| --- | --- |
| `Sources/UsageBar/ScreenEdge.swift` | 保留四边几何、保活区域、悬停触发；尺寸改为调用方传入，并沿可见区域布局 |
| `Sources/UsageBar/RailPresentation.swift` | 保留命中区域与摆动数学；材质改为跟随系统外观 |
| `Sources/UsageBar/Views.swift` 中 ClotheslineShape、WoodenPeg、RailView、HangingCard | 提取装饰；容器改为泛型 item 与 card closure；排序拖动限制到夹子 |
| `Sources/UsageBar/AppController.swift` | 精简为窗口、屏幕、菜单、拖动、详情管理，移除账号与认证服务 |
| `Sources/UsageBar/AppModel.swift` 的展示状态 | 改为独立 RailState 与持久化 UUID 顺序 |
| `Tests/UsageBarTests` 中边缘／展示测试 | 改编为独立测试，补入负坐标、排序增删与系统边界检查 |

这是一次独立提取，不对来源应用实施依赖迁移或行为改造。通用文件当前随模板源码分发，没有另行发布二进制库。

## 首版已验证

- macOS 本机构建：Debug、Release 均通过，无第三方 Swift 包。
- 10 项 XCTest 全通过：屏幕布局、物理边缘、悬停、防误收起、固定持久化、顺序恢复与增删、重复展开、命中区域、摆动停止／衰减、四方向转轴。
- 脚手架生成独立目录；支持空格、中文与引号；拒绝覆盖已有目录和非法名称；产品名与模板默认值同名时替换正确。
- 新项目运行 build_app.py 成功，`.app` 签名校验通过。
- 真实 NSHostingView 渲染四边 × 两尺寸 × 深浅色 16 张 PNG；抽查横向、竖向、深浅色与底部布局。
- 打包应用已启动；实机通过 UI 操作验证：固定状态恢复、卡内完成按钮、辅助功能“后移”排序、位置菜单与左侧切换、打开详情并收起挂卡。
- 启动测试发现并修复 bundle ID 与 UserDefaults suite 同名返回 nil 的问题；打包版使用 `.standard`，未打包调试使用 `.development` 域。

## 验证限制

没有实机覆盖多显示器拔插、跨屏拖动、全屏 Spaces、实际 VoiceOver 朗读、系统减少透明度／减少动态效果开关。几何与动效单元测试不代替这些场景。悬停／离开计时通过测试并观察到未固定窗口自动收起，但未对四边完整指针路径逐一回放。

示例状态数据是固定值，操作卡的完成状态只存在于视图内，切换布局可能重置；真实业务应把状态放在宿主 ObservableObject 或持久化存储。模板未实现后台下载、AI 调度、剪贴板或文件处理。

## 首次文件产品复用

2026-10-23 使用脚手架构建“稍后阅读”。新增 FileDropHostingView 与 FileDragTracker，并将控制器的可选 onFileDrop、业务菜单注入和文件选择器显隐接口回补模板。7 个通用源文件在模板和新产品中逐字节相同。模板现有 12 项测试通过。

新产品的文件复制、去重、原生拖出、预览和阅读状态仍属于业务层。2026-10-24 新产品的 15 项测试通过，实机验证批量文件导入、Quick Look、默认应用打开、重启文件与已读状态恢复；Finder 双向拖放由用户亲自操作并确认成功。自动操作工具未完成跨窗口拖放回放，不将人工确认写成自动化端到端测试。拖出文件独立哈希比对、废纸篓 UI 往返与多屏行为仍未覆盖。

实机发现未固定窗口启动后容易过快收起，模板增加 `revealForInteraction()`，启动／重新打开时保留 10 秒操作时间，并在应用代理中处理 reopen。常规边缘悬停和离开延迟保持原有行为。
