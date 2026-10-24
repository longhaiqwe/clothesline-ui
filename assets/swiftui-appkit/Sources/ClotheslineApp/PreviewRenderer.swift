import AppKit
import SwiftUI

/// Render the actual components with isolated defaults, without starting a menu-bar agent.
@MainActor
enum PreviewRenderer {
    static func render(to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let suite = "clothesline.preview.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        for edge in ScreenEdge.allCases {
            for compact in [false, true] {
                for dark in [false, true] {
                    let state = RailState(defaults: defaults)
                    state.edge = edge
                    state.compact = compact
                    let size = edge.vertical ? CGSize(width: state.cardSize.width + 72, height: 800)
                        : CGSize(width: 1100, height: state.cardSize.height + 102)
                    let root = ClotheslineView(state: state, items: DemoItem.samples, title: { $0.title }) {
                        DemoCard(item: $0, compact: $1, open: {})
                    }.environment(\.colorScheme, dark ? .dark : .light)
                    let host = NSHostingView(rootView: root)
                    let window = NSWindow(contentRect: CGRect(origin: .zero, size: size),
                                          styleMask: [.borderless], backing: .buffered, defer: false)
                    window.isReleasedWhenClosed = false
                    window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
                    window.contentView = host
                    host.frame = CGRect(origin: .zero, size: size)
                    host.layoutSubtreeIfNeeded()
                    RunLoop.main.run(until: Date().addingTimeInterval(0.1))
                    host.layoutSubtreeIfNeeded()
                    guard let bitmap = host.bitmapImageRepForCachingDisplay(in: host.bounds) else {
                        throw NSError(domain: "PreviewRenderer", code: 1)
                    }
                    host.cacheDisplay(in: host.bounds, to: bitmap)
                    guard let data = bitmap.representation(using: .png, properties: [:]) else {
                        throw NSError(domain: "PreviewRenderer", code: 2)
                    }
                    let name = "\(edge.rawValue)-\(compact ? "compact" : "standard")-\(dark ? "dark" : "light").png"
                    try data.write(to: directory.appendingPathComponent(name))
                    window.close()
                }
            }
        }
    }
}
