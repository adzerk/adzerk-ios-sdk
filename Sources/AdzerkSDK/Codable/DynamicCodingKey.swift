//
//  DynamicCodingKey.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/3/20.
//

import Foundation

/// Used to dynamically hold & reference Codable keys as string values.
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}
