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
public struct PlacementResponse: Codable {
    public let decisions: [String: PlacementDecision]
    public let extraAttributes: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case decisions
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
        
        var decisions: [String: PlacementDecision] = [:]
        for divNameKey in decisionsContainer.allKeys {
            // provode the divName so that Placement decision can be decoded properly (since this will be missing from the nested container)
            divNameProvider.currentDivName = divNameKey.stringValue
            let decision = try decisionsContainer.decode(PlacementDecision.self, forKey: divNameKey)
            decisions[divNameKey.stringValue] = decision
        }
        
        self.decisions = decisions
        self.extraAttributes = try decoder.decodeAnyCodableTree(using: DynamicCodingKey.self, ignoringKeys: [DynamicCodingKey(stringValue: "decisions")!])
    }
}
