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
    
    var keystore: UserKeyStore!
    
    override func setUp() {
        keystore = FakeKeyStore()
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
