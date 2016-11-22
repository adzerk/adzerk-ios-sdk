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
@objc open class ADZKeychainUserKeyStore : NSObject, ADZUserKeyStore {
    let adzUserKey = "ADZUserKey"
    
    /** 
        Retrieve the saved userKey from the Keychain.
    
        - returns: the user key, or nil if none exists
    */
    open func currentUserKey() -> String? {
        if let data = ADZKeychainHelper.fetch(adzUserKey) {
            return String(data: data as Data, encoding: String.Encoding.utf8)
        }
        
        return nil
    }
    
    /**
        Saves the userKey to the keychain.
    
        - parameter key: the user key to save
    */
    open func saveUserKey(_ key: String) {
        let data = key.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let _ = ADZKeychainHelper.save(adzUserKey, data: data)
    }
    
    /** 
        Removes the userKey from the keychain.
    */
    open func removeUserKey() {
        ADZKeychainHelper.delete(adzUserKey)
    }
    
}
