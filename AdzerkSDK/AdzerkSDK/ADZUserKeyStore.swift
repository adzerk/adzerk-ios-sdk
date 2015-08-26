//
//  ADZUserKeyStore.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/26/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

public protocol ADZUserKeyStore {
    func currentUserKey() -> String?
    func saveUserKey(key: String)
}
