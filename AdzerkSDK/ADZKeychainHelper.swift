//
//  ADZKeychainHelper.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/26/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

class ADZKeychainHelper {
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
    
    class func fetch(key: String) -> NSData? {
        let query = [
            (kSecClass as String) : (kSecClassGenericPassword as String),
            (kSecAttrAccount as String) : key,
            (kSecReturnData as String) : kCFBooleanTrue,
            (kSecMatchLimit as String) : kSecMatchLimitOne
        ] as CFDictionaryRef
        
        var keychainData: Unmanaged<AnyObject>?
        let status: OSStatus = SecItemCopyMatching(query, &keychainData)
        if status == noErr {
            return keychainData?.takeRetainedValue() as? NSData
        } else {
            return nil
        }
    }
    
}