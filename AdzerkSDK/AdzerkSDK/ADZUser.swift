//
//  ADZUser.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/11/15.
//  Copyright © 2015 Adzerk. All rights reserved.
//

import Foundation

@objc public class ADZUser : NSObject {
    public let userKey: String!
    
    init?(dictionary: [String: AnyObject]) {
        guard let key = dictionary["key"] as? String else {
            self.userKey = ""
            super.init()
            return nil
        }
        self.userKey = key
        super.init()
    }
}