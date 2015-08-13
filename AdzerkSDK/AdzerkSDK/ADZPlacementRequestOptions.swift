//
//  ADZPlacementRequestOptions.swift
//  AdzerkSDK
//
//  Created by ben on 8/13/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

public struct ADZPlacementRequestOptions {
    public var keywords: [String]?
    public var blockedCreatives: [Int]?
    
    // format:
    // [
    //    "flightId": [time1, time2]
    // ]
    public var flightViewTimes: [String: [Int]]?
    public var referrer: String?
    public var url: String?
    public var userKey: String?
}