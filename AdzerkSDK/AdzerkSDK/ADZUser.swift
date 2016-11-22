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
@objc open class ADZUser : NSObject {
    open let userKey: String!
    open let blockedItems: [String: AnyObject]!
    open let interests: [String]!
    open let customProperties: [String: AnyObject]!
    open let optOut: Bool
    
    init?(dictionary: [String: AnyObject]) {
        guard let
            key = dictionary["key"] as? String,
            let blockedItems = dictionary["blockedItems"] as? [String: AnyObject],
            let interests = dictionary["interests"] as? [String],
            let customProperties = dictionary["custom"] as? [String: AnyObject],
            let optOut = dictionary["optOut"] as? NSNumber
        
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
