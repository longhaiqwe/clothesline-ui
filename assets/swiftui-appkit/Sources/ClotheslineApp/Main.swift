import AppKit
import SwiftUI

@MainActor
final class DemoAppDelegate: NSObject, NSApplicationDelegate {
    private var rail: RailWindowController?
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        // A bundled app must use .standard for its own domain; a matching suite returns nil.
        let defaults = Bundle.main.bundleIdentifier == nil
            ? UserDefaults(suiteName: DemoConfig.bundleID + ".development") ?? .standard
            : .standard
        let state = RailState(defaults: defaults)
        rail = RailWindowController(state: state, title: DemoConfig.appName, symbol: DemoConfig.menuSymbol) {
            ClotheslineView(state: state, items: DemoItem.samples, title: { $0.title }) { item, compact in
                DemoCard(item: item, compact: compact) { [weak self] in
                    self?.rail?.showDetail(title: item.title) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(item.title).font(.largeTitle)
                            Text("这是独立模板中的演示详情。将 DemoItem 和 DemoCard 替换为你的业务模型和界面。")
                        }.padding(32).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        rail?.revealForInteraction()
        return true
    }
    func applicationWillTerminate(_ notification: Notification) { rail?.stop() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

@main
struct ClotheslineEntry {
    @MainActor static func main() throws {
        let app = NSApplication.shared
        if let index = CommandLine.arguments.firstIndex(of: "--preview-directory"),
           CommandLine.arguments.indices.contains(index + 1) {
            try PreviewRenderer.render(to: URL(fileURLWithPath: CommandLine.arguments[index + 1]))
            return
        }
        let delegate = DemoAppDelegate()
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
    }
}
