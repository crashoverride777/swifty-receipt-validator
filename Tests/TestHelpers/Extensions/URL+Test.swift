import Foundation

extension URL {
    static let test: URL = {
        guard let url = URL(string: "https://www.example.com") else {
            fatalError("Invalid test url")
        }
        return url
    }()
}
