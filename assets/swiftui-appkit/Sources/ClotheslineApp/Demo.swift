import SwiftUI

enum DemoConfig {
    static let appName = "Clothesline Demo"
    static let bundleID = "local.clothesline.demo"
    // Choose a symbol for the product's purpose, independently of the clothesline decoration.
    static let menuSymbol = "square.stack"
}

struct DemoItem: Identifiable {
    enum Kind { case status, content, action }
    let id: UUID
    let title: String
    let subtitle: String
    let kind: Kind
    static let samples = [
        DemoItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                 title: "视频转码", subtitle: "状态卡 · 示例数据", kind: .status),
        DemoItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                 title: "随手摘录", subtitle: "内容卡 · 本地示例", kind: .content),
        DemoItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                 title: "工作清单", subtitle: "操作卡 · 本地示例", kind: .action)
    ]
}

struct DemoCard: View {
    let item: DemoItem
    let compact: Bool
    var open: () -> Void
    @State private var completed = false
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 12) {
            Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
            Text(item.title).font(.headline)
            switch item.kind {
            case .status:
                Text("68%").font(.system(size: compact ? 24 : 32, weight: .semibold, design: .rounded))
                ProgressView(value: 0.68).accessibilityLabel("示例进度")
            case .content:
                Text("把眼前需要的事挂起来，给正在做的事留出空间。")
                    .font(compact ? .caption : .body).lineLimit(compact ? 2 : 4)
            case .action:
                Button(completed ? "已完成 ✓" : "标记完成") { completed.toggle() }
                    .buttonStyle(.bordered)
            }
            Spacer(minLength: 0)
            Button("查看详情", action: open).font(.caption)
        }
        .padding(compact ? 14 : 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
