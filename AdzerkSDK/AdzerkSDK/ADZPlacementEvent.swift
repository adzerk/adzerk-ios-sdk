//
//  ADZPlacementEvent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/17/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/** 
    Returns tracking URLs for any requested custom events.
*/
public class ADZPlacementEvent : NSObject {
    @objc public let id: Int
    @objc public let url: String
    
    /** Initialize a new struct given a JSON dictionary. Expects the keys `id` and `url` 
        to be present in the dictionary.
    */
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        url = dictionary["url"] as! String
    }
}
