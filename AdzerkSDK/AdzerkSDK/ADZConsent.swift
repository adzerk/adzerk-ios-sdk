//
//  ADZConsent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 5/3/18.
//  Copyright © 2018 Adzerk. All rights reserved.
//

import Foundation

/**
 Represents a user's consent to tracking for GDPR compliance.
 */
public class ADZConsent : NSObject {
    public var gdpr: Bool
    
    public init(gdpr: Bool) {
        self.gdpr = gdpr
        super.init()
    }
 
    /**
     Initializes with a dictionary. Expects the `gdpr` key to be present and contain a boolean value.
    */
    public init?(dictionary: [String: AnyObject]) {
        gdpr = (dictionary["gdpr"] as? NSNumber)?.boolValue ?? false
        super.init()
    }
    
    /**
     Converts the object to a JSON dictionary representation.
    */
    public func toJSONDictionary() -> [String: Any] {
        return [
            "gdpr": gdpr
        ]
    }
}
