//
//  ADZUserKeyStore.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/26/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/** Provides the interface for storing and retrieving the user DB key
    that the API uses to identify a user. If none is passed to an initial request,
    the server will generate a new one and return it.
    `AdzerkSDK` will use its configured `ADZUserKeyStore` to store this key.
    
    The default behavior is to store this value in the keychain, securely. If
    you need to store this alongside your user record instead, then you can
    create a custom implementation of `ADZUserKeyStore` and save it wherever is
    appropriate for your application.
*/
@objc public protocol ADZUserKeyStore {
    /** Fetches the current user's key, if we have one saved. */
    func currentUserKey() -> String?

    /** Saves a key for the current user. */
    func saveUserKey(key: String)
    
    /** Removes a saved user key. */
    func removeUserKey()
}
