//
//  ADZPlacement.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/11/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/** Specifies a placement's details to request. */
public struct ADZPlacement {
    
    /** The name of the div */
    public let divName: String
    
    /** The network ID. If none is specified it retrieves the value from `AdzerkSDK.defaultNetworkId` */
    public let networkId: Int
    
    /** The site ID. If none is specified it retrieves the value from `AdzerkSDK.defaultSiteId` */
    public let siteId: Int
    
    /** An array of integers representing the ad types to request. The full list can be found at https://github.com/adzerk/adzerk-api/wiki/Ad-Types . */
    public let adTypes: [Int]
    
    public var zoneIds: [Int]?
    public var eventIds: [Int]?
    
    public var properties: [String: AnyObject]?
    public var campaignId: Int?
    public var flightId: Int?
    public var adId: Int?
    
    public init(divName: String, networkId: Int, siteId: Int, adTypes: [Int]) {
        self.divName = divName
        self.networkId = networkId
        self.siteId = siteId
        self.adTypes = adTypes
    }
    
    public init?(divName: String, adTypes: [Int]) {
        self.divName = divName
        self.adTypes = adTypes
        if let networkId = AdzerkSDK.defaultNetworkId, siteId = AdzerkSDK.defaultSiteId {
            self.networkId = networkId
            self.siteId = siteId
        } else {
            println("Warning: Using this initializer requires AdzerkSDK.defaultNetworkId and Adzerk.defaultSiteId to be defined")
            return nil
        }
    }
    
    public func serialize() -> [String : AnyObject] {
        var json: [String: AnyObject] = [
                "divName"  : divName,
                "networkId": networkId,
                "siteId"   : siteId,
                "adTypes"  : adTypes
        ]
        
        if let eventIds = eventIds {
            json["eventIds"] = eventIds
        }
        
        if let zoneIds = zoneIds {
            json["zoneIds"] = zoneIds
        }
        
        if let campaignId = campaignId {
            json["campaignId"] = campaignId
        }
        
        if let flightId = flightId {
            json["flightId"] = flightId
        }
        
        if let adId = adId {
            json["adId"] = adId
        }

        return json
    }
}