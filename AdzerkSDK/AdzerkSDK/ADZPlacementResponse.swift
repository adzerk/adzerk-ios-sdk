//
//  ADZPlacementResponse.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/14/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/**
    Top level response object for placement requests.
    Documentation can be found at: http://help.adzerk.com/hc/en-us/articles/203193935-Response
*/
public class ADZPlacementResponse: NSObject {
    public let decisions: [String: ADZPlacementDecision]
    public let extraAttributes: [String: AnyObject]
    
    init?(dictionary: [String: AnyObject]) {
        if let decisionsDict = dictionary["decisions"] as? [String: AnyObject] {
            
            let keys = Array(decisionsDict.keys)
            
            let decs = compact(keys.map { (key: String) -> ADZPlacementDecision? in
                let decisionAttributes = decisionsDict[key] as? [String: AnyObject]
                return ADZPlacementDecision(name: key, dictionary: decisionAttributes)
            })
            
            decisions = groupBy(decs) { $0.divName }
        } else {
            decisions = [String: ADZPlacementDecision]()
        }
        
        var otherAttribs = [String: AnyObject]()
        for (key, val) in dictionary {
            if key == "decisions" {
                continue
            }
            otherAttribs[key] = val
        }
        extraAttributes = otherAttribs
    }
}
