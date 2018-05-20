//
//  ADZConsent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 5/3/18.
//  Copyright © 2018 Adzerk. All rights reserved.
//

import Foundation

public class ADZConsent : NSObject {
    public var gdpr: Bool
    
    public init(gdpr: Bool) {
        self.gdpr = gdpr
        super.init()
    }
    
    public init?(dictionary: [String: AnyObject]) {
        gdpr = (dictionary["gdpr"] as? NSNumber)?.boolValue ?? false
        super.init()
    }
}
