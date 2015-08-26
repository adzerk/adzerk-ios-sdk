//
//  ADZKeychainUserKeyStore.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/26/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

public class ADZKeychainUserKeyStore : ADZUserKeyStore {
    let adzUserKey = "ADZUserKey"
    
    public func currentUserKey() -> String? {
        if let data = ADZKeychainHelper.fetch(adzUserKey) {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        }
        
        return nil
    }
    
    public func saveUserKey(key: String) {
        let data = key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        ADZKeychainHelper.save(key, data: data)
    }
    
    
}