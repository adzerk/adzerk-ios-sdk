//
//  ADZPlacementContent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/17/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

public struct ADZPlacementContent {
    let type: String?
    let template: String?
    let data: [String: AnyObject]?
    let body: String?
    
    public init(dictionary: [String: AnyObject]) {
        type = dictionary["type"] as? String
        template = dictionary["template"] as? String
        data = dictionary["data"] as? [String: AnyObject]
        body = dictionary["body"] as? String
    }
}