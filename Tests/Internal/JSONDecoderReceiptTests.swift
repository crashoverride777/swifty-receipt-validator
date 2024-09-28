import Foundation
import Testing
@testable import SwiftyReceiptValidator

struct JSONDecoderReceiptTests {
    
    @Test func dateDecodingStrategy() {
        let sut: JSONDecoder = .receiptResponse
        switch sut.dateDecodingStrategy {
        case .formatted(let formatter):
            #expect(formatter.calendar == Calendar(identifier: .iso8601))
            #expect(formatter.locale == .current)
            #expect(formatter.dateFormat == "yyyy-MM-dd HH:mm:ss VV")
        default:
            Issue.record("Wrong dateDecodingStrategy")
        }
    }
    
    @Test func keyDecodingStrategy() {
        let sut: JSONDecoder = .receiptResponse
        switch sut.keyDecodingStrategy {
        case .convertFromSnakeCase:
            break
        default:
            Issue.record("Wrong keyDecodingStrategy")
        }
    }
}
