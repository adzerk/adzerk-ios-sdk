//
//  AdzerkJSONEncoder.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/23/20.
//

import Foundation

class AdzerkJSONEncoder: JSONEncoder, @unchecked Sendable {
    override init() {
        super.init()
        dateEncodingStrategy = .iso8601
    }
}

