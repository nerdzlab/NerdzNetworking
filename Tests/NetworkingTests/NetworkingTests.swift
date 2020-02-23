import XCTest
@testable import Networking

final class NetworkingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Networking().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
