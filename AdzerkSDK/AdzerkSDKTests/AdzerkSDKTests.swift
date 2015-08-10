//
//  AdzerkSDKTests.swift
//  AdzerkSDKTests
//
//  Created by Ben Scheirman on 8/10/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import AdzerkSDK
import XCTest

class AdzerkSDKTests: XCTestCase {

    let networkId = 9792
    let siteId = 306998
    var sdk: AdzerkSDK!
    
    override func setUp() {
        super.setUp()
        sdk = AdzerkSDK(networkId: networkId, siteId: siteId)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCanRequestPlacement() {
        let placementDiv = "div1"
        
        let expectation = expectationWithDescription("API response received")
        sdk.requestPlacementInDiv("div1") { (response) -> () in
            switch response {
            case .Success(let data):
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [String: AnyObject] {
                    println("Received: \(json)")
                } else {
                    println("Couldn't parse as JSON")
                }
            case .BadRequest(let statusCode, let body):
                println("Bad request (HTTP \(statusCode)):  \(body)")
            case .Error(let error):
                println("Error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil) 
    }
}
