import XCTest
@testable import swift_beconde

final class swift_becondeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(swift_beconde().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
