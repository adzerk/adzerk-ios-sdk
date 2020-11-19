//
//  Placement.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation

public protocol Placement: Codable {
    /** The name of the div */
    var divName: String { get }
    
    /** The network ID. If none is specified it retrieves the value from `AdzerkSDK.defaultNetworkId` */
    var networkId: Int { get }
    
    /** The site ID. If none is specified it retrieves the value from `AdzerkSDK.defaultSiteId` */
    var siteId: Int { get }
    
    var count: Int? { get }
    
    func options() -> PlacementRequest<Self>.Options
    
    /** Validates the placement values before sending. An error describing the issue will be thrown if invalid. */
    func validate() throws
}

public extension Placement {
    func options() -> PlacementRequest<Self>.Options {
        PlacementRequest<Self>.Options()
    }
    
    func validate() throws {
        /* implementers can override this if needed */
    }
}

public struct Placements {
    /// Use this placement type if you don't need to pass any additional options.
    public static func standard(divName: String, adTypes: [Int], count: Int? = nil) -> StandardPlacement {
        StandardPlacement(divName: divName, adTypes: adTypes, count: count)
    }
    
    /// Use this placement type if you need to pass additional options.
    public static func custom(divName: String, adTypes: [Int], count: Int? = nil) -> CustomPlacement {
        CustomPlacement(divName: divName, adTypes: adTypes, count: count)
    }
}

/// Use this placement type if you don't need to pass any additional options.
public class StandardPlacement: Placement {
    /** The name of the div */
    public let divName: String
    
    /** The network ID. If none is specified it retrieves the value from `AdzerkSDK.defaultNetworkId` */
    public let networkId: Int
    
    /** The site ID. If none is specified it retrieves the value from `AdzerkSDK.defaultSiteId` */
    public let siteId: Int
    
    public let count: Int?
    
    /** An array of integers representing the ad types to request. The full list can be found at https://github.com/adzerk/adzerk-api/wiki/Ad-Types . */
    let adTypes: [Int]
    
    var zoneIds: [Int]?
    var eventIds: [Int]?
    var campaignId: Int?
    var flightId: Int?
    var adId: Int?
    
    public convenience init(divName: String, adTypes: [Int], count: Int? = nil) {
        guard let networkId = DecisionSDK.defaultNetworkId,
              let siteId = DecisionSDK.defaultSiteId else {
            fatalError("Warning: Using this initializer requires AdzerkSDK.defaultNetworkId and Adzerk.defaultSiteId to be defined")
        }
        self.init(networkId: networkId, siteId: siteId, divName: divName, adTypes: adTypes, count: count)
    }

    public init(networkId: Int, siteId: Int, divName: String, adTypes: [Int], count: Int? = nil) {
        self.networkId = networkId
        self.siteId = siteId
        self.divName = divName
        self.adTypes = adTypes
        self.count = count
    }
    
    public func validate() throws {
        if adTypes.isEmpty {
            throw AdzerkError.missingAdType
        }
    }
}

/// Use this placement type if you need to pass additional options.
public class CustomPlacement: StandardPlacement {
    var additionalOptions: [String: AnyCodable] = [:]
    
    enum CodingKeys: String, CodingKey {
        case additionalOptions
    }
    
    public override init(networkId: Int, siteId: Int, divName: String, adTypes: [Int], count: Int?) {
        super.init(networkId: networkId, siteId: siteId, divName: divName, adTypes: adTypes, count: count)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(additionalOptions, forKey: .additionalOptions)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        additionalOptions = try container.decode([String: AnyCodable].self, forKey: .additionalOptions)
        try super.init(from: decoder)
    }
}
