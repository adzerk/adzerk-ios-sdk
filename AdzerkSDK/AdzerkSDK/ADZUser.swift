//
//  ADZUser.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/11/15.
//  Copyright © 2015 Adzerk. All rights reserved.
//

import Foundation

/** 
    Contains the information known about a user in UserDB. Returned
    by calling `readUser` on `AdzerSDK`.
*/
@objc public class ADZUser : NSObject {
    public let userKey: String!
    public let blockedItems: [String: AnyObject]!
    public let interests: [String]!
    public let customProperties: [String: AnyObject]!
    public let optOut: Bool
    
    init?(dictionary: [String: AnyObject]) {
        guard let
            key = dictionary["key"] as? String,
            blockedItems = dictionary["blockedItems"] as? [String: AnyObject],
            interests = dictionary["interests"] as? [String],
            customProperties = dictionary["custom"] as? [String: AnyObject],
            optOut = dictionary["optOut"] as? NSNumber
        
            else {
                self.userKey = ""
                self.blockedItems = [:]
                self.interests = []
                self.customProperties = [:]
                self.optOut = false
            super.init()
            return nil
        }
        
        self.userKey = key
        self.blockedItems = blockedItems
        self.interests = interests
        self.customProperties = customProperties
        self.optOut = optOut.boolValue
        super.init()
    }
}