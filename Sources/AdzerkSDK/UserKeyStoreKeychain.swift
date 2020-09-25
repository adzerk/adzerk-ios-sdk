//
//  UserKeyStoreKeychain.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation

/**
    Provides secure storage for the User key via the iOS Keychain. This is the default implementation of `UserKeyStore`.
*/
public class UserKeyStoreKeychain : UserKeyStore {
    let userKeychainKey = "ADZUserKey"
    
    /**
        Retrieve the saved userKey from the Keychain.
    
        - returns: the user key, or nil if none exists
    */
    public var currentUserKey: String? {
        if let data = KeychainHelper.fetch(userKeychainKey) {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        
        return nil
    }
    
    /**
        Saves the userKey to the keychain.
    
        - parameter key: the user key to save
    */
    public func save(userKey: String) {
        let data = userKey.data(using: .utf8, allowLossyConversion: false)!
        _ = KeychainHelper.save(userKeychainKey, data: data)
    }
    
    /**
        Removes the userKey from the keychain.
    */
    public func removeUserKey() {
        KeychainHelper.delete(userKeychainKey)
    }
}
