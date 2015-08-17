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
    let adId: Int?
    let creativeId: Int?
    let flightId: Int?
    let campaignId: Int?
    let clickUrl: String?
    let impressionUrl: String?
    let contents: [ADZPlacementContent]?
    let events: [ADZPlacementEvent]?
    
    public init?(name: String, dictionary: [String: AnyObject]?) {
        println(dictionary)
        divName = name
        adId = dictionary?["adId"] as? Int
        creativeId = dictionary?["creativeId"] as? Int
        flightId = dictionary?["flightId"] as? Int
        campaignId = dictionary?["campaignId"] as? Int
        clickUrl = dictionary?["clickUrl"] as? String
        impressionUrl = dictionary?["impressionUrl"] as? String
        contents = (dictionary?["contents"] as? [[String:AnyObject]])?.map { ADZPlacementContent(dictionary: $0) }
        events = (dictionary?["events"] as? [[String: AnyObject]])?.map { ADZPlacementEvent(dictionary: $0) }
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