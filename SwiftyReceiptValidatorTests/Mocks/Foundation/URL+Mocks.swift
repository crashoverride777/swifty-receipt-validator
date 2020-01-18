//
//  Extensions.swift
//  SwiftyReceiptValidatorTests
//
//  Created by Dominik Ringler on 18/01/2020.
//  Copyright © 2020 Dominik. All rights reserved.
//

import Foundation

extension URL {
    
    static let test: URL = {
        guard let url = URL(string: "https://www.example.com") else {
            fatalError("Invalid test url")
        }
        return url
    }()
}
