//
//  ADZPlacementDecision.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/14/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

public struct ADZPlacementDecision {
    let divName: String
    let adId: Int? = nil
    let flightId: Int? = nil
    let campaignId: Int? = nil
    let clickUrl: String? = nil
    let impressionUrl: String? = nil
    
    public init?(name: String, dictionary: [String: AnyObject]) {
        divName = name
    }
}

//"adId": 111,
//"creativeId": 222,
//"flightId": 333,
//"campaignId": 444,
//"clickUrl": "http://engine.adzerk.net/r?...",
//"contents": [
//{
//"type": "html",
//"template": "image",
//"data": {
//"imageUrl": "http://static.adzerk.net/cat-eating-spaghetti.jpg",
//"title": "ZOMG LOOK AT THIS FRICKING CAT",
//"width": 350,
//"height": 350
//},
//"body": "<a href='...'><img src='http://static.adzerk.net/cat-eating-spaghetti.jpg' title='ZOMG LOOK AT THIS FRICKING CAT' width="350" height="350"></a>"
//}
//],
//"impressionUrl": "http://engine.adzerk.net/i.gif?..."
//},