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

    public init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lat = try container.decodeCoordinate(forKey: .lat)
        lon = try container.decodeCoordinate(forKey: .lon)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(lon, forKey: .lon)
    }
}

private extension KeyedDecodingContainer where Key == GeoPoint.CodingKeys {
    /** The transport type is a number, but responses used to carry these as strings,
        so both are accepted. */
    func decodeCoordinate(forKey key: Key) throws -> Double {
        if let value = try? decode(Double.self, forKey: key) {
            return value
        }
        return Double(try decode(String.self, forKey: key)) ?? 0
    }
}
