import XCTest
@testable import Mogami

final class MogamiTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(mogami().text, "Hello, World!")
    }
}
