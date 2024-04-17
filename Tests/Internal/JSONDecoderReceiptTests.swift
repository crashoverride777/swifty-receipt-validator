import XCTest
@testable import SwiftyReceiptValidator

final class JSONDecoderReceiptTests: XCTestCase {

    // MARK: - Tests
    
    func testDateDecodingStrategy() {
        let sut: JSONDecoder = .receiptResponse
        switch sut.dateDecodingStrategy {
        case .formatted(let formatter):
            XCTAssertEqual(formatter.calendar, Calendar(identifier: .iso8601))
            XCTAssertEqual(formatter.locale, .current)
            XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd HH:mm:ss VV")
        default:
            XCTFail("Wrong dateDecodingStrategy")
        }
    }
    
    func testKeyDecodingStrategy() {
        let sut: JSONDecoder = .receiptResponse
        switch sut.keyDecodingStrategy {
        case .convertFromSnakeCase:
            break
        default:
            XCTFail("Wrong keyDecodingStrategy")
        }
    }
}
