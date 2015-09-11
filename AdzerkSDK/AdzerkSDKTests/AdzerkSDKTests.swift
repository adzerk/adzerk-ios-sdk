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
    func assertSuccessfulResponse(expectation: XCTestExpectation) -> (ADZResponse) -> () {
        return assertResponse(expectation)
    }
    
    // Assert that the API response is called. Calls the validationHandler in the case of .Success for callers to 
    // validate the response structure.
    func assertResponse(expectation: XCTestExpectation, validationHandler: (ADZPlacementResponse -> ())? = nil) -> (ADZResponse -> ()) {
        return { (response) in
            switch response {
            case .Success(let resp):
                validationHandler?(resp)
            case .BadResponse(let body):
                XCTFail("Unrecognizable response: \(body)")
            case .BadRequest(let statusCode, let body):
                XCTFail("Bad request (HTTP \(statusCode)):  \(body)")
            case .Error(let error):
                XCTFail("Received Error: \(error)")
            }
            expectation.fulfill()
        }
    }
    
    func testCanRequestSimplePlacement() {
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
        let placement = ADZPlacement(divName: "div1", adTypes: [5])!
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
        sdk.requestPlacement(placement, completion: assertResponse(expectation, validationHandler: { response in
            if let dec = response.decisions["div1"] {
                XCTAssertTrue(dec.adId != nil, "Ad id was not set")
                XCTAssertTrue(dec.creativeId != nil, "Creative id was not set")
                XCTAssertTrue(dec.flightId != nil, "Flight id was not set")
                XCTAssertTrue(dec.campaignId != nil, "Campaign id was not set")
                XCTAssertTrue(dec.clickUrl != nil, "Click URL was not set")
                
                if let contents = dec.contents {
                    XCTAssertEqual(contents.count, 1, "Should have had 1 item in contents")
                    if let content = contents.first {
                        XCTAssertEqual(content.type!, "html", "content type should be html")
                        XCTAssertEqual(content.template!, "image", "content template should be image")
                        XCTAssertTrue(content.data != nil, "content data should have been set")
                        XCTAssertTrue(content.body != nil, "content body should have been set")
                    }
                    
                }
                XCTAssertEqual((dec.events?.count)!, 0, "events should have been an empty array")
                
            } else {
                XCTFail("couldn't find div1 in response")
            }
        }))
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testCanRequestMultiplePlacements() {
        let placement1 = ADZPlacement(divName: "div1", adTypes: [5])!
        let placement2 = ADZPlacement(divName: "div2", adTypes: [5])!
        let expectation = expectationWithDescription("API response received")
        sdk.requestPlacements([placement1, placement2], completion: assertResponse(expectation, validationHandler: { response in
            XCTAssertTrue(response.decisions["div1"] != nil)
            XCTAssertTrue(response.decisions["div2"] != nil)
        }))
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testCanRequestPlacementsWithOptions() {
        let placement1 = ADZPlacement(divName: "div1", adTypes: [5])!
        placement1.adId = 1
        placement1.campaignId = 1
        placement1.flightId = 1
        placement1.eventIds = [123]
        placement1.properties = ["key":"val"]
        
        let expectation = expectationWithDescription("API response received")
        let options = ADZPlacementRequestOptions()
        options.flightViewTimes = [
            "1234": [151243, 5124312]
        ]
        
        options.blockedCreatives = [1,2,3]
        options.keywords = ["cheese", "apples", "wine"]
        sdk.requestPlacements([placement1], options: options,completion: assertResponse(expectation, validationHandler: { response in
            XCTAssertTrue(response.decisions["div1"] != nil)
        }))
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testSavesUserKey() {
        let fakeKeyStore = FakeKeyStore()
        let sdk = AdzerkSDK(userKeyStore: fakeKeyStore)
        let expectation = expectationWithDescription("API response received")
        sdk.requestPlacementInDiv("div1", adTypes: [5], completion: assertSuccessfulResponse(expectation))
        waitForExpectationsWithTimeout(3.0, handler: nil)
        
        XCTAssertTrue(fakeKeyStore.key != nil, "User key was not set")
    }
    
    func testSendsSavedUserKey() {
        let fakeKeyStore = FakeKeyStore()
        fakeKeyStore.key = "testkey12345"
        
        let sdk = AdzerkSDK(userKeyStore: fakeKeyStore)
        let expectation = expectationWithDescription("API response received")
        sdk.requestPlacementInDiv("div1", adTypes: [5], completion: assertSuccessfulResponse(expectation))
        waitForExpectationsWithTimeout(3.0, handler: nil)
        
        XCTAssertEqual(fakeKeyStore.currentUserKey()!, "testkey12345")
    }
    
    func testCanPostUserProperties() {
        let properties = [
            "foo" : "bar",
            "isCustom": true,
            "numberOfGems": 25
        ]
        
        let userKey = "userKey123"
        let expectation = expectationWithDescription("API response received")
        sdk.postUserProperties(userKey, properties: properties) { success, error in
            XCTAssertNil(error)
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
    
    func testCanReadUser() {
        let userKey = "userKey123"
        let expectation = expectationWithDescription("API response received")
        sdk.readUser(userKey) { user, error in
            expectation.fulfill()
            XCTAssertNotNil(user)
            XCTAssertEqual(user?.userKey, "userKey123")
        }
        
        waitForExpectationsWithTimeout(3.0, handler: nil)
    }
}
