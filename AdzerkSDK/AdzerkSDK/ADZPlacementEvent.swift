//
//  ADZPlacementEvent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/17/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

public struct ADZPlacementEvent {
    let id: Int
    let url: String
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        url = dictionary["url"] as! String
    }
}
