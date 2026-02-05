//
//  User.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/16/20.
//

import Foundation

public struct User: Codable {
    public let key: String
    /// The assigned cohort for the User
    public let group: Int?
    
    public let blockedItems: [String: AnyCodable]
    public let interests: [String]
    public let custom: [String: AnyCodable]
    public let optOut: Bool
    
    /** Indicates the user's current value for GDPR consent. */
    public let consent: Consent?
}
