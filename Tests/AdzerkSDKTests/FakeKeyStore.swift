//
//  File.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/4/20.
//

import Foundation
@testable import AdzerkSDK

class FakeKeyStore: UserKeyStore {
    var currentUserKey: String?
    
    func save(userKey: String) {
        currentUserKey = userKey
    }
    
    func removeUserKey() {
        currentUserKey = nil
    }
}
