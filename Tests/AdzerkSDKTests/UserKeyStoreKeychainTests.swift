//
//  UserKeyStoreKeychainTests.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation
import XCTest
@testable import AdzerkSDK

class UserKeyStoreKeychainTests: XCTestCase {
    
    var keystore: UserKeyStoreKeychain!
    
    override func setUp() {
        keystore = UserKeyStoreKeychain()
    }
    
    func testSaveRetrieveDelete() {
        keystore.save(userKey: "test1")
        XCTAssertEqual("test1", keystore.currentUserKey)
        keystore.removeUserKey()
        XCTAssertNil(keystore.currentUserKey)
    }
    
    static var allTests = [
        ("testSaveRetrieveDelete", testSaveRetrieveDelete)        
    ]
}
