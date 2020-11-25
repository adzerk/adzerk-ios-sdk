//
//  PlacementRequest.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation

/// Represents the HTTP request made for requesting placements.
public struct PlacementRequest<P: Placement>: Codable {
    
    public struct Options {
        public var userKey: String?
        public var keywords: [String]?
        public var blockedCreatives: [Int]?
        public var flightViewTimes: [String: [Int]]?
        public var url: String?
        
        /** Indicates the user's consent status for GDPR compliance. */
        public var consent: Consent?
        
        /**
         Pass any additional values here and they will be sent as top-level
         parameters in the placement request. This can be used to adopt new
         parameters before they are added to the SDK.
         */
        public var additionalOptions: [String: AnyCodable]?
    }
    
    let placements: [P]
    let user: UserIdentifier?
    let blockedCreatives: [Int]?
    let flightViewTimes: [String: [Int]]?
    let keywords: [String]?
    let consent: Consent?
    let additionalOptions: [String: AnyCodable]?
    
    init(placements: [P], options: Options? = nil, userKeyStore: UserKeyStore) {
        self.placements = placements
        user = (options?.userKey ?? userKeyStore.currentUserKey).flatMap(UserIdentifier.init)
        blockedCreatives = options?.blockedCreatives
        flightViewTimes = options?.flightViewTimes
        keywords = options?.keywords
        consent = options?.consent
        additionalOptions = options?.additionalOptions
    }
    
    func encodeBody() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(self)
        DecisionSDK.logger.log(.debug, message: "Placement request JSON:\n\n\(String(data: data, encoding: .utf8) ?? "")")
        
        return data
    }
}
