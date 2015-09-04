//
//  ADZPlacementDecision.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/14/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/**
    Response structure for decisions, found in a placement response. Each decision
    will be represented as one of these.
*/
@objc public class ADZPlacementDecision {
    /** The name of the div requested */
    public let divName: String
    
    public let adId: Int?
    public let creativeId: Int?
    public let flightId: Int?
    public let campaignId: Int?
    public let clickUrl: String?
    public let impressionUrl: String?
    
    /** An array of `ADZPlacementContent`, representing the actual contents
        to display for this decision, if there are any.
    */
    public let contents: [ADZPlacementContent]?
    
    /** An array of `ADZPlacementEvent`, representing the events for this decision,
        if there are any. */
    public let events: [ADZPlacementEvent]?
    
    /** All of the attributes will be present in this dictionary,
        in case there are additional attributes being sent that are not modeled
        as properties.
    */
    public let allAttributes: [String: AnyObject]?
    
    /** Initializes the struct based on a JSON dictionary.
        @param name The name of the div for this decision
        @param JSON dictionary of attributes returned from the server
        @returns an initialized struct, or nil if the response format was not recognized
    */
    public init?(name: String, dictionary: [String: AnyObject]?) {
        println(dictionary)
        divName = name
        allAttributes = dictionary
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
