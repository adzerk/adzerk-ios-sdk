//
//  ADZPlacement.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/11/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

public struct ADZPlacement {
    
    public let divName: String
    public let networkId: Int
    public let siteId: Int
    public let adTypes: [Int]
    public var zoneIds: [Int] = []
    public var eventIds: [Int] = []
    public var properties: [String: AnyObject] = [:]
    
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
}