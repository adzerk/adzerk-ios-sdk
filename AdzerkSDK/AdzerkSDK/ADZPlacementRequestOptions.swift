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
    public var flightViewTimes: [String: [Int]]?
    public var url: String?
    public var userKey: String?
    public var additionalOptions: [String: AnyObject]?
    
    public init() {
        
    }
}