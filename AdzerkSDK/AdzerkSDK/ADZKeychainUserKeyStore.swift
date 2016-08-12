//
//  ADZKeychainUserKeyStore.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/26/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/**
    Provides secure storage for the User key via the iOS Keychain. This is the default implementation of `ADZUserKeyStore`.
*/
@objc public class ADZKeychainUserKeyStore : NSObject, ADZUserKeyStore {
    let adzUserKey = "ADZUserKey"
    
    /** 
        Retrieve the saved userKey from the Keychain.
    
        - returns: the user key, or nil if none exists
    */
    public func currentUserKey() -> String? {
        if let data = ADZKeychainHelper.fetch(adzUserKey) {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        }
        
        return nil
    }
    
    /**
        Saves the userKey to the keychain.
    
        - parameter key: the user key to save
    */
    public func saveUserKey(key: String) {
        let data = key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        ADZKeychainHelper.save(adzUserKey, data: data)
    }
    
    /** 
        Removes the userKey from the keychain.
    */
    public func removeUserKey() {
        ADZKeychainHelper.delete(adzUserKey)
    }
    
}