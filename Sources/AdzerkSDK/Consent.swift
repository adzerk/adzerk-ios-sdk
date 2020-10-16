//
//  Consent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation

public struct Consent: Codable {
    /// Indicates the user has provided consent per GDPR.
    public let gdpr: Bool?
    
    public init(gdpr: Bool) {
        self.gdpr = gdpr
    }
}
