//
//  AdzerkJSONDecoder.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/4/20.
//

import Foundation

class AdzerkJSONDecoder: JSONDecoder, @unchecked Sendable {
    override init() {
        super.init()
        
        dateDecodingStrategy = .iso8601
        userInfo = [
            PlacementDecision.divNameProviderCodingInfoKey: PlacementDecision.PlacementDivProvider()
        ]
    }
}
