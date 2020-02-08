import XCTest
@testable import swifty_receipt_validator

final class swifty_receipt_validatorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(swifty_receipt_validator().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
