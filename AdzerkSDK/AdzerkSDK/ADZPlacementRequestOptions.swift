//
//  ADZPlacementRequestOptions.swift
//  AdzerkSDK
//
//  Created by ben on 8/13/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/** Provides a mechanism for adding top-level metadata to the placement request. */
public class ADZPlacementRequestOptions: NSObject {
    public var keywords: [String]?
    public var blockedCreatives: [Int]?
    public var flightViewTimes: [String: [Int]]?
    public var url: String?
    
    /** The user key for this request. If nil, the current saved user key will be used from
        the configured `ADZUserKeyStore` on `AdzerkSDK`.
    */
    public var userKey: String?
    
    /** Any additional parameters can be provided here and will be added to the request */
    public var additionalOptions: [String: AnyObject]?
    
    public override init() {
    }
}
