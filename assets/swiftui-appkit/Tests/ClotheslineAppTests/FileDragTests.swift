import XCTest
@testable import ClotheslineApp

final class FileDragTests: XCTestCase {
    func testOldPasteboardDoesNotRevealRailDuringAnOrdinaryClick() {
        var tracker = FileDragTracker()
        XCTAssertFalse(tracker.update(buttonDown: false, changeCount: 7, hasFileURLs: true))
        XCTAssertFalse(tracker.update(buttonDown: true, changeCount: 7, hasFileURLs: true))
        XCTAssertTrue(tracker.update(buttonDown: true, changeCount: 8, hasFileURLs: true))
        XCTAssertTrue(tracker.update(buttonDown: true, changeCount: 8, hasFileURLs: true))
        XCTAssertFalse(tracker.update(buttonDown: false, changeCount: 8, hasFileURLs: true))
        XCTAssertFalse(tracker.update(buttonDown: true, changeCount: 8, hasFileURLs: true))
    }
    func testNonFileDragsDoNotEnableFileIntake() {
        var tracker = FileDragTracker()
        XCTAssertFalse(tracker.update(buttonDown: false, changeCount: 1, hasFileURLs: false))
        XCTAssertFalse(tracker.update(buttonDown: true, changeCount: 2, hasFileURLs: false))
    }
}
