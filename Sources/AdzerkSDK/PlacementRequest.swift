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
        public var enableBotFiltering: Bool = false
        
        /** Indicates the user's consent status for GDPR compliance. */
        public var consent: Consent?
        
        /**
         Pass any additional values here and they will be sent as top-level
         parameters in the placement request. This can be used to adopt new
         parameters before they are added to the SDK.
         */
        public var additionalOptions: [String: AnyCodable]?
        public var userGroup: [Int]?

        public init(userKey: String? = nil, userGroup: [Int]? = nil, keywords: [String]? = nil, blockedCreatives: [Int]? = nil, flightViewTimes: [String: [Int]]? = nil, url: String? = nil, enableBotFiltering: Bool = false) {
            self.userKey = userKey
            self.userGroup = userGroup
            self.keywords = keywords
            self.blockedCreatives = blockedCreatives
            self.flightViewTimes = flightViewTimes
            self.url = url
            self.enableBotFiltering = enableBotFiltering
        }
    }
    
    let placements: [P]
    let user: UserIdentifier?
    let blockedCreatives: [Int]?
    let flightViewTimes: [String: [Int]]?
    let keywords: [String]?
    let consent: Consent?
    let enableBotFiltering: Bool
    let additionalOptions: [String: AnyCodable]?
    
    init(placements: [P], options: Options? = nil, userKeyStore: UserKeyStore) {
        self.placements = placements
        user = (options?.userKey ?? userKeyStore.currentUserKey).flatMap { key in
            UserIdentifier(key: key, group: options?.userGroup)
        }
        blockedCreatives = options?.blockedCreatives
        flightViewTimes = options?.flightViewTimes
        keywords = options?.keywords
        consent = options?.consent
        additionalOptions = options?.additionalOptions
        enableBotFiltering = options?.enableBotFiltering ?? false
    }
    
    func encodeBody() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        var data = try encoder.encode(self)
        
        if var json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            json["placements"] = placements.compactMap { try? $0.bodyJson() }
            if let additionalOptions = json["additionalOptions"] as? [String: Any] {
                json.merge(additionalOptions) { (current, _) in current }
                json.removeValue(forKey: "additionalOptions")
            }
            data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        }
        
        DecisionSDK.logger.log(.debug, message: "Placement request JSON:\n\n\(String(data: data, encoding: .utf8) ?? "")")
        
        return data
    }
    
    private func validatePlacements() throws {
        try placements.forEach { placement in
            try placement.validate()
        }
    }
}
