import XCTest
@testable import ClotheslineApp

final class RailStyleTests: XCTestCase {
    @MainActor
    func testDefaultsAndUnknownStyleFallback() {
        let suite = "clothesline.style.\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        XCTAssertEqual(RailState(defaults: defaults).style, .system)
        XCTAssertEqual(RailState(defaults: defaults, defaultStyle: .looseleaf).style, .looseleaf)
        defaults.set("future-style", forKey: RailStyle.defaultsKey)
        XCTAssertEqual(RailState(defaults: defaults).style, .system)
    }

    @MainActor
    func testSavedStyleOverridesProductDefaultWithoutChangingLayoutOrOrder() {
        let suite = "clothesline.style.\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let state = RailState(defaults: defaults)
        state.edge = .right
        state.compact = true
        state.pinned = true
        let ids = DemoItem.samples.map(\.id)
        state.shift(ids[0], by: 1, among: ids)
        let order = state.order
        state.style = .looseleaf
        let restored = RailState(defaults: defaults)
        XCTAssertEqual(restored.style, .looseleaf)
        XCTAssertEqual(restored.edge, .right)
        XCTAssertTrue(restored.compact)
        XCTAssertTrue(restored.pinned)
        XCTAssertEqual(restored.order, order)
        restored.style = .system
        XCTAssertEqual(RailState(defaults: defaults, defaultStyle: .looseleaf).style, .system)
    }
}
