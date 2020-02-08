import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(swifty_receipt_validatorTests.allTests),
    ]
}
#endif
