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
}

public struct Placements {
    public static func standard(divName: String, adTypes: [Int]) -> StandardPlacement {
        StandardPlacement(divName: divName, adTypes: adTypes)
    }
}

public class StandardPlacement: Placement {
        
    /** The name of the div */
    public let divName: String
    
    /** The network ID. If none is specified it retrieves the value from `AdzerkSDK.defaultNetworkId` */
    public let networkId: Int
    
    /** The site ID. If none is specified it retrieves the value from `AdzerkSDK.defaultSiteId` */
    public let siteId: Int
    
    /** An array of integers representing the ad types to request. The full list can be found at https://github.com/adzerk/adzerk-api/wiki/Ad-Types . */
    let adTypes: [Int]
    
    var zoneIds: [Int]?
    var eventIds: [Int]?
    var campaignId: Int?
    var flightId: Int?
    var adId: Int?
    
    /**
     Pass any additional values here and they will be sent as top-level
     parameters in the placement request. This can be used to adopt new parameters before they are added to the SDK.
     */
    var additionalOptions: [String: PlacementAdditionalOption]?
    
    public convenience init(divName: String, adTypes: [Int]) {
        guard let networkId = AdzerkSDK.defaultNetworkId,
              let siteId = AdzerkSDK.defaultSiteId else {
            fatalError("Warning: Using this initializer requires AdzerkSDK.defaultNetworkId and Adzerk.defaultSiteId to be defined")
        }
        self.init(networkId: networkId, siteId: siteId, divName: divName, adTypes: adTypes)
    }

    public init(networkId: Int, siteId: Int, divName: String, adTypes: [Int]) {
        self.networkId = networkId
        self.siteId = siteId
        self.divName = divName
        self.adTypes = adTypes
    }
}
