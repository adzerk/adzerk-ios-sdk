//
//  PlacementDecision.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/3/20.
//

import Foundation

public struct PlacementDecision: Codable {
    
    public static let divNameProviderCodingInfoKey = CodingUserInfoKey(rawValue: "currentDivNameProvider")!
    public class PlacementDivProvider {
        var currentDivName: String?
    }
    
    struct DivNameMissing: Error {}
    
    /// The name of the div requested
    public let divName: String
    
    public let adId: Int?
    public let creativeId: Int?
    public let flightId: Int?
    public let campaignId: Int?
    public let clickUrl: URL?
    public let impressionUrl: URL?
    
    /** An array of `PlacementDecision.Content` values, representing the actual contents
        to display for this decision, if there are any.
        */
    public let contents: [Content]
    
    /** An array of `PlacementDecision.Event` values, representing the events for this decision,
        if there are any. */
    public let events: [Event]
    
    /** All of the attributes will be present in this dictionary,
        in case there are additional attributes being sent that are not modeled
        as properties.
        */
    public let allAttributes: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case divName
        case adId
        case creativeId
        case flightId
        case campaignId
        case clickUrl
        case impressionUrl
        case contents
        case events
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(divName, forKey: .divName)
        try container.encode(adId, forKey: .adId)
        try container.encode(creativeId, forKey: .creativeId)
        try container.encode(flightId, forKey: .flightId)
        try container.encode(campaignId, forKey: .campaignId)
        try container.encode(clickUrl, forKey: .clickUrl)
        try container.encode(impressionUrl, forKey: .impressionUrl)
        try container.encode(contents, forKey: .contents)
        try container.encode(events, forKey: .events)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let embeddedDivName = try container.decodeIfPresent(String.self, forKey: .divName) {
            divName = embeddedDivName
        } else {
            guard let currentDivName = decoder.currentUserInfoDivName else {
                throw DivNameMissing()
            }
            divName = currentDivName
        }
        adId = try container.decodeIfPresent(Int.self, forKey: .adId)
        creativeId = try container.decodeIfPresent(Int.self, forKey: .creativeId)
        flightId = try container.decodeIfPresent(Int.self, forKey: .flightId)
        campaignId = try container.decodeIfPresent(Int.self, forKey: .campaignId)
        clickUrl = try container.decodeIfPresent(URL.self, forKey: .clickUrl)
        impressionUrl = try container.decodeIfPresent(URL.self, forKey: .impressionUrl)
        contents = try container.decode([Content].self, forKey: .contents)
        events = try container.decode([Event].self, forKey: .events)
        
        allAttributes = try decoder.decodeAnyCodableTree(using: DynamicCodingKey.self)
    }
}

extension Decoder {
    var currentUserInfoDivName: String? {
        // this is nested inside of a container and the divName is provided via user info
        guard let divNameProvider = userInfo[PlacementDecision.divNameProviderCodingInfoKey] as? PlacementDecision.PlacementDivProvider else {
            fatalError("divName is missing from the container and userInfo did not contain a 'currentDivNameProvider' coding info key to provide one")
        }
        
        return divNameProvider.currentDivName
    }
}

extension PlacementDecision: CustomStringConvertible {
    public var description: String {
        return "PlacementDecision: divName=\(divName) adId=\(adId ?? 0) creativeId=\(creativeId ?? 0)"
    }
}
