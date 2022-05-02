import Foundation

extension JSONDecoder {
    
    static let receiptResponse: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
