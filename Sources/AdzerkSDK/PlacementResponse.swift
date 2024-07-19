//
//  PlacementResponse.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/3/20.
//

import Foundation

/**
    Top level response object for placement requests.
    Documentation can be found at: https://dev.adzerk.com/reference/response
*/
public struct PlacementResponse: Codable, Sendable {
    public let decisions: [String: [PlacementDecision]]
    public let extraAttributes: [String: AnyCodable]
    public let user: UserIdentifier?
    
    enum CodingKeys: String, CodingKey {
        case decisions
        case user
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(decisions, forKey: .decisions)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decisionsContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .decisions)
        
        guard let divNameProvider = decoder.userInfo[PlacementDecision.divNameProviderCodingInfoKey] as? PlacementDecision.PlacementDivProvider else {
            fatalError("You must using AdzerkJSONDecoder or provide your own value for userInfo's 'currentDivNameProvider' coding info key")
        }
        
        var decisions: [String: [PlacementDecision]] = [:]
        for divNameKey in decisionsContainer.allKeys {
            // provode the divName so that Placement decision can be decoded properly (since this will be missing from the nested container)
            divNameProvider.currentDivName = divNameKey.stringValue
            
            // first try to decode a single value
            do {
                if let decision =
                    try decisionsContainer.decodeIfPresent(PlacementDecision.self, forKey: divNameKey) {
                    decisions[divNameKey.stringValue] = [decision]
                }
            } catch {
                // fall back to decoding an array (for multi-winner responses)
                let decisionArray = try decisionsContainer.decodeIfPresent([PlacementDecision].self, forKey: divNameKey)
                decisions[divNameKey.stringValue] = decisionArray
            }
        }
        
        self.decisions = decisions
        self.user = try container.decodeIfPresent(UserIdentifier.self, forKey: .user)
        self.extraAttributes = try decoder.decodeAnyCodableTree(using: DynamicCodingKey.self, ignoringKeys: [DynamicCodingKey(stringValue: "decisions")!])
    }
}
