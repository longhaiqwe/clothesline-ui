# clothesline-ui · 晾衣杆界面 Skill

用 SwiftUI＋AppKit 构建 macOS 屏幕边缘的晾衣杆、挂卡与悬停展开界面。提供 Agent 使用说明、可运行模板、脚手架和测试。

从灵感晾台、PinSnip、AI 用量看板的共同呈现方式出发，实际代码从 AI 用量看板提取；首个复用产品是 [稍后阅读](https://github.com/longhaiqwe/ReadLater)。

![使用 Skill 构建的稍后阅读，实机截图](docs/screenshots/readlater.png)

## 下载与安装

[下载 clothesline-ui.zip](https://github.com/longhaiqwe/clothesline-ui/releases/latest/download/clothesline-ui.zip) · [版本记录](https://github.com/longhaiqwe/clothesline-ui/releases)

解压后，把完整的 `clothesline-ui` 文件夹放入 `~/.codex/skills/`。保留 `SKILL.md`、`references`、`scripts` 和 `assets` 的目录结构。若已有同名技能，先备份再替换。

也可以安装到一个尚不存在的目录：

```sh
git clone https://github.com/longhaiqwe/clothesline-ui.git ~/.codex/skills/clothesline-ui
```

新开一个 Codex 对话，明确调用：

> 使用 clothesline-ui 做一个稍后阅读，支持把本地文件拖进去暂存，再拖到其他应用里使用。先复用模板，再实现业务功能。

其他支持本地 Skill 的 Agent，可按其规则载入本仓库的 SKILL.md。模板独立可运行，不要求使用特定 Agent。

## 生成与构建

需要 macOS 14+、包含 macOS SDK 的 Swift 5.9+ 工具链、Python 3 和系统 codesign。可通过 Xcode 或 Apple Command Line Tools 提供构建工具。

```sh
python3 scripts/scaffold.py ~/Projects/MyClothesline \
  --name '任务晾台' --bundle-id 'local.example.taskrail' --symbol 'checklist'
cd ~/Projects/MyClothesline
swift test
python3 scripts/build_app.py
```

目标目录必须不存在。应用生成于项目的 `dist/`，使用本机 ad-hoc 签名。示例卡片需要替换为真实业务模型和操作。

## 可以复用什么

- 四边吸附、悬停展开、离开收起、固定与位置锁定。
- 绳子、夹子、卡片摆动、沿衣杆方向滚动、逐卡排序。
- 标准／迷你尺寸，系统深浅色与辅助显示适配。
- 泛型卡片容器，业务菜单和详情入口。
- 可选原生文件 URL 拖入；文件拖动时唤出边缘面板。
- 启动及重新打开时保留 10 秒操作时间。

文件复制、持久化、去重、网络请求、认证等属于宿主产品。模板不提供这些业务服务，也不是已经发布到 Swift Package Index 的组件库。

[完整 Skill](SKILL.md) · [接入说明](references/integration.md) · [交互约束](references/interaction.md) · [来源与验证范围](references/provenance.md)

适合短状态、临时文件、摘录和少量快捷动作；长文编辑与复杂管理更适合单独窗口。

## 验证与授权

首版独立模板 12 项 XCTest 通过；稍后阅读 15 项测试通过，并验证预览、打开和重启恢复，双向拖放由用户实测确认。多屏拔插、完整 VoiceOver 流程等未覆盖，见来源文档。

本项目采用 [MIT](LICENSE)。衣杆样式沿 AI 用量看板 → [IdeaLine](https://github.com/longhaiqwe/IdeaLine) → [Tendedero](https://github.com/alejandrobujan/tendedero) 继承；保留 [第三方授权](assets/swiftui-appkit/THIRD_PARTY_LICENSES.txt)。PinSnip 提供产品层面的启发，本仓库未提取其代码或素材。
