//
//  UserDB.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/16/20.
//

import Foundation

public class UserDB {
    
    private let networkId: Int
    private let keyStore: UserKeyStore
    
    public init(host: String, networkId: Int, keyStore: UserKeyStore) {
        self.networkId = networkId
        self.keyStore = keyStore
    }
    
    public func readUser() {
        
    }
}
