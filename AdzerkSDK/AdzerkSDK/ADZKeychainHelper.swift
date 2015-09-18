//
//  ADZKeychainHelper.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/26/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/** Provides easy get/set access for simple values in the iOS Keychain. */
class ADZKeychainHelper {
    
    /** 
        Saves data to the keychain.
        @param key an identifier under which the data will be stored
        @param data the data to save
        @returns true if the value was set successfully
    */
    class func save(key: String, data: NSData) -> Bool {
        let query = [
            (kSecClass as String) : (kSecClassGenericPassword as String),
            (kSecAttrAccount as String) : key,
            (kSecValueData as String) : data
        ] as CFDictionaryRef
        
        // remove item if it exists already
        SecItemDelete(query)
        
        // save item
        let status: OSStatus = SecItemAdd(query, nil)
        
        return status == noErr
    }
    
    /**
        Retrieves a values from the keychain.
        @param key the identifier the data was originally saved with
        @returns the saved data, or nil if nothing was saved for this key
    */
    class func fetch(key: String) -> NSData? {
        let query = [
            (kSecClass as String) : (kSecClassGenericPassword as String),
            (kSecAttrAccount as String) : key,
            (kSecReturnData as String) : kCFBooleanTrue,
            (kSecMatchLimit as String) : kSecMatchLimitOne
        ] as CFDictionaryRef
        
        var keychainData: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query, &keychainData)
        if status == noErr {
            return keychainData as? NSData
        } else {
            return nil
        }
    }
    
}