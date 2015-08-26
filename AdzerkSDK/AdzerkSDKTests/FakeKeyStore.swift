//
//  FakeKeyStore.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/26/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

class FakeKeyStore :ADZUserKeyStore {
    var key: String?
    
    func saveUserKey(key: String) {
        self.key = key
    }
    
    func currentUserKey() -> String? {
        return key
    }
}