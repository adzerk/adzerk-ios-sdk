//
//  GeoPoint.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 11/25/20.
//

import Foundation

/// Used to provide matchedPoints behavior for GeoDistance targeting.
public struct GeoPoint: Codable {
    public let lat: Double
    public let lon: Double
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
    }
    
    // the actual transport type gives us a string, so we want to convert that to/from a double with a custom encode/decode implementation
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latString = try container.decode(String.self, forKey: .lat)
        let lonString = try container.decode(String.self, forKey: .lon)
        
        lat = Double(latString) ?? 0
        lon = Double(lonString) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(lat), forKey: .lat)
        try container.encode(String(lon), forKey: .lon)
    }
}
