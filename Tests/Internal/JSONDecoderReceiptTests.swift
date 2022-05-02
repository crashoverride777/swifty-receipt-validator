import XCTest
@testable import SwiftyReceiptValidator

class JSONDecoderReceiptTests: XCTestCase {

    // MARK: - Tests
    
    func test_dateDecodingStrategy() {
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
    
    func test_keyDecodingStrategy() {
        let sut: JSONDecoder = .receiptResponse
        switch sut.keyDecodingStrategy {
        case .convertFromSnakeCase:
            break
        default:
            XCTFail("Wrong keyDecodingStrategy")
        }
    }
}
