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
        AdzerkSDK.defaultNetworkId = networkId
        AdzerkSDK.defaultSiteId = siteId
        sdk = AdzerkSDK()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDefaultNetworkIdAndSiteId() {
        XCTAssertEqual(AdzerkSDK.defaultNetworkId!, networkId, "network id was not set")
        XCTAssertEqual(AdzerkSDK.defaultSiteId!, siteId, "site id was not set")
    }
    
    func testCreatePlacementWithDivAndAdTypes() {
        let placement = ADZPlacement(divName: "asdf", adTypes: [])
        XCTAssertTrue(placement != nil, "was nil")
    }
    
    // Assert that the API response is called and returns .Success
    // response data is ignored
    func assertSuccessfulResponse(expectation: XCTestExpectation) -> (ADZPlacementResponse) -> () {
        return assertResponse(expectation)
    }
    
    // Assert that the API response is called. Calls the validationHandler in the case of .Success for callers to 
    // validate the response structure.
    func assertResponse(expectation: XCTestExpectation, validationHandler: (AnyObject -> ())? = nil) -> (ADZPlacementResponse -> ()) {
        return { (response) in
            switch response {
            case .Success(let data):
                let obj: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil)!
                println(obj)
                validationHandler?(obj)
            case .BadRequest(let statusCode, let body):
                XCTFail("Bad request (HTTP \(statusCode)):  \(body)")
            case .Error(let error):
                XCTFail("Received Error: \(error)")
            }
            expectation.fulfill()
        }
    }
    
    func testCanRequestSimplePlacement() {
        let placementDiv = "div1"
        let expectation = expectationWithDescription("API response received")
        sdk.requestPlacementInDiv("div1", adTypes: [5], completion: assertSuccessfulResponse(expectation))
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testCanRequestPlacementWithAdditionalParameters() {
        let placement = ADZPlacement(divName: "div1", adTypes: [])!
        let expectation = expectationWithDescription("Successful API Response received")
        sdk.requestPlacement(placement, completion: assertSuccessfulResponse(expectation))
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testCanRequestPlacementwithAllParameters() {
        var placement = ADZPlacement(divName: "div1", adTypes: [5])!
        placement.zoneIds = [136961]
        placement.properties = [
            "custom_key": "custom_value",
            "foos": ["bar", "baz", "quux"],
            "minions": [
                "stuart" : 12,
                "kevin" : 13,
                "bob" : 18
            ]
        ]
        let expectation = expectationWithDescription("API response received")
        sdk.requestPlacement(placement, completion: assertResponse(expectation, validationHandler: { obj in
            
            if let json   = obj as? [String: AnyObject],
                decisions = json["decisions"] as? [String: AnyObject],
                div1      = decisions["div1"] as? [String: AnyObject] {
                // found div1
            } else {
                XCTFail("Did not find div1 in response")
            }
        }))
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testCanRequestMultiplePlacements() {
        let placement1 = ADZPlacement(divName: "div1", adTypes: [5])!
        let placement2 = ADZPlacement(divName: "div2", adTypes: [5])!
        let expectation = expectationWithDescription("API response received")
        sdk.requestPlacement([placement1, placement2], completion: assertResponse(expectation, validationHandler: { obj in
            if let json   = obj as? [String: AnyObject],
                decisions = json["decisions"] as? [String: AnyObject],
                div1      = decisions["div1"] as? [String: AnyObject],
                div2      = decisions["div2"] as? [String: AnyObject] {
                    // found div1 and div2
            } else {
                XCTFail("Did not find div1 and div2 in response")
            }
        }))
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testCanRequestPlacementsWithOptions() {
        var placement1 = ADZPlacement(divName: "div1", adTypes: [5])!
        placement1.adId = 1
        placement1.campaignId = 1
        placement1.flightId = 1
        placement1.eventIds = [123]
        placement1.properties = ["key":"val"]
        
        let expectation = expectationWithDescription("API response received")
        var options = ADZPlacementRequestOptions()
        options.flightViewTimes = [
            "1234": [151243, 5124312]
        ]
        
        options.blockedCreatives = [1,2,3]
        options.referrer = "test referrer"
        options.keywords = ["cheese", "apples", "wine"]
        sdk.requestPlacement([placement1], options: options,completion: assertResponse(expectation, validationHandler: { obj in
            if let json   = obj as? [String: AnyObject],
                decisions = json["decisions"] as? [String: AnyObject] {
                    XCTAssertTrue(decisions.keys.first == "div1", "div1 was not found in response")
            } else {
                XCTFail("Did not find decisions container in response")
            }
        }))
        waitForExpectationsWithTimeout(3.0, handler: nil)
        
    }
    
    
}
