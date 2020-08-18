//
//  AdzerkSDKTests.swift
//  AdzerkSDKTests
//
//  Created by Ben Scheirman on 8/10/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import XCTest
@testable import AdzerkSDK

class AdzerkSDKTests: XCTestCase {

    let networkId = 23
    let siteId = 306998
    var sdk: AdzerkSDK!

    override func setUp() {
        super.setUp()
        AdzerkSDK.defaultNetworkId = networkId
        AdzerkSDK.defaultSiteId = siteId
        ADZLogger.logLevel = ADZLogger.LevelDebug
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

    func testSerializePlacement() {
        let placement = ADZPlacement(divName: "aoeu", adTypes: [5])

        placement!.zoneIds = [136961]
        placement!.properties = [
            "some_key": "some_value",
            "pets": [
              [
                "name":    "Steve",
                "species": "cat",
                "age":     12
              ],
              [
                "name":    "Barbara",
                "species": "dog",
                "age":     7
              ]
            ]
        ]

        XCTAssertTrue(placement != nil, "placement was nil")

        let json = placement!.serialize()

        if let divName = json["divName"] as? String {
          XCTAssertEqual(divName, "aoeu", "expected divName to be \"aoeu\", got \"\(divName)\"")
        } else {
          XCTFail("Unable to read json.divName as a string.")
        }

        // set by default value on setup
        if let pNetworkId = json["networkId"] as? Int {
          XCTAssertEqual(pNetworkId, networkId, "expected networkId to be \(networkId), got \(pNetworkId)")
        } else {
          XCTFail("Unable to read json.networkId as an int.")
        }

        // set by default value on setup
        if let pSiteId = json["siteId"] as? Int {
          XCTAssertEqual(pSiteId, siteId, "expected siteId to be \(siteId), got \(pSiteId)")
        } else {
          XCTFail("Unable to read json.siteId as an int.")
        }

        if let adTypes = json["adTypes"] as? [Int] {
          let adType = adTypes[0]
          XCTAssertEqual(adType, 5, "expected adType to be 5, got \(adType)")

        } else {
          XCTFail("Unable to read json.adTypes as an array.")
        }

        if let zoneIds = json["zoneIds"] as? [Int] {
            let zoneId = zoneIds[0]
            XCTAssertEqual(zoneId, 136961, "expected zoneId to be 136961, got \(zoneId)")
        } else {
          XCTFail("Unable to read json.zoneIds as an array.")
        }

        if let properties = json["properties"] as? [String: AnyObject] {
            if let some_value = properties["some_key"] as? String {
                XCTAssertEqual(some_value, "some_value", "expected \"some_value\", got \"\(some_value)\"")
            } else {
                XCTFail("Unable to read json.properties.some_key as a string.")
            }

            let pets = properties["pets"] as! [Any]
            let steve = pets[0] as! [String:Any]
            let species = steve["species"] as! String
            
            XCTAssertEqual(species, "cat", "expected Steve's species to be \"cat\", got \"\(species)\"")
            
            let age = steve["age"] as! Int
            XCTAssertEqual(age, 12, "expected Steve's age to be 12, got \(age)")
            
            let barbara = pets[1] as! [String:Any]
            let bspecies = barbara["species"]! as! String
            XCTAssertEqual(bspecies, "dog", "expected barbara's species to be \"dog\", got \"\(bspecies)\"")

            let bage = barbara["age"] as! Int
            XCTAssertEqual(bage, 7, "expected barbara's age to be 7, got \(bage)")

        } else {
          XCTFail("Unable to read json.properties as an object.")
        }
    }

    // Assert that the API response is called and returns .Success
    // response data is ignored
    func assertSuccessfulResponse(expectation: XCTestExpectation) -> (ADZResponse) -> () {
        return assertResponse(expectation: expectation)
    }

    // Assert that the API response is called. Calls the validationHandler in the case of .Success for callers to
    // validate the response structure.
    func assertResponse(expectation: XCTestExpectation, validationHandler: ((ADZPlacementResponse) -> ())? = nil) -> ((ADZResponse) -> ()) {
        return { (response) in
            switch response {
            case .success(let resp):
                validationHandler?(resp)
            case .badResponse(let body):
                XCTFail("Unrecognizable response: \(body)")
            case .badRequest(let statusCode, let body):
                XCTFail("Bad request (HTTP \(statusCode)):  \(body)")
            case .error(let error):
                XCTFail("Received Error: \(error)")
            }
            expectation.fulfill()
        }
    }
    
    func testCallsBackOnMainQueue() {
        let expectationResult = expectation(description: "API response received")
        sdk.requestPlacementInDiv("div1", adTypes: [5]) { response in
            XCTAssert(Thread.isMainThread, "Called back on background thread")
            expectationResult.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testCallsBackOnProvidedQueue() {
        let myQueue = DispatchQueue.global(qos: .background)
        let sdk = AdzerkSDK(userKeyStore: ADZKeychainUserKeyStore(), queue: myQueue)
        let exp = expectation(description: "API Response Received")
        sdk.requestPlacementInDiv("div1", adTypes: [5]) { response in
            XCTAssertFalse(Thread.isMainThread, "Was not called on provided queue")
            exp.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanRequestSimplePlacement() {
        let expectationResult = expectation(description: "API response received")
        sdk.requestPlacementInDiv("div1", adTypes: [5], completion: assertSuccessfulResponse(expectation: expectationResult))
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanRequestPlacementWithAdditionalParameters() {
        let placement = ADZPlacement(divName: "div1", adTypes: [])!
        let expectationResult = expectation(description: "Successful API Response received")
        sdk.requestPlacement(placement, completion: assertSuccessfulResponse(expectation: expectationResult))
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanRequestPlacementwithAllParameters() {
        let placement = ADZPlacement(divName: "div1", adTypes: [5])!
        placement.flightId = 699801
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
        let expectationResult = expectation(description: "API response received")
        sdk.requestPlacement(placement, completion: assertResponse(expectation: expectationResult, validationHandler: { response in
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
                        
                        // THIS ROW FAILS - THE RAW RESPONSE JSON DOES NOT CONTAIN "template" PARAMETER!
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
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanRequestMultiplePlacements() {
        let placement1 = ADZPlacement(divName: "div1", adTypes: [5])!
        let placement2 = ADZPlacement(divName: "div2", adTypes: [5])!
        let expectationResult = expectation(description: "API response received")
        sdk.requestPlacements([placement1, placement2], completion: assertResponse(expectation: expectationResult, validationHandler: { response in
            XCTAssertTrue(response.decisions["div1"] != nil)
            XCTAssertTrue(response.decisions["div2"] != nil)
        }))
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanRequestPlacementsWithOptions() {
        let placement1 = ADZPlacement(divName: "div1", adTypes: [5])!
        placement1.adId = 1
        placement1.campaignId = 1
        placement1.flightId = 1
        placement1.eventIds = [123]
        placement1.properties = ["key":"val"]

        let expectationResult = expectation(description: "API response received")
        let options = ADZPlacementRequestOptions()
        options.flightViewTimes = [
            "1234": [151243, 5124312]
        ]
        options.consent = ADZConsent(gdpr: true)

        options.blockedCreatives = [1,2,3]
        options.keywords = ["cheese", "apples", "wine"]
        sdk.requestPlacements([placement1], options: options,completion: assertResponse(expectation: expectationResult, validationHandler: { response in
            XCTAssertTrue(response.decisions["div1"] != nil)
        }))
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testSavesUserKey() {
        let fakeKeyStore = FakeKeyStore()
        let sdk = AdzerkSDK(userKeyStore: fakeKeyStore)
        let expectationResult = expectation(description: "API response received")
        sdk.requestPlacementInDiv("div1", adTypes: [5], completion: assertSuccessfulResponse(expectation: expectationResult))
        waitForExpectations(timeout: 3.0, handler: nil)

        XCTAssertTrue(fakeKeyStore.key != nil, "User key was not set")
    }

    func testSendsSavedUserKey() {
        let fakeKeyStore = FakeKeyStore()
        fakeKeyStore.key = "testkey12345"

        let sdk = AdzerkSDK(userKeyStore: fakeKeyStore)
        let expectationResult = expectation(description: "API response received")
        sdk.requestPlacementInDiv("div1", adTypes: [5], completion: assertSuccessfulResponse(expectation: expectationResult))
        waitForExpectations(timeout: 3.0, handler: nil)

        XCTAssertEqual(fakeKeyStore.currentUserKey()!, "testkey12345")
    }

    func testCanPostUserProperties() {
        let properties: [String:Any] = [
            "foo" : "bar",
            "isCustom": true,
            "numberOfGems": 25
        ]

        let userKey = "userKey123"
        let expectationResult = expectation(description: "API response received")
        sdk.postUserProperties(userKey, properties: properties) { success, error in
            XCTAssertNil(error)
            XCTAssertTrue(success)
            expectationResult.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testCanReadUser() {
        let userKey = "userKey123"
        let expectationResult = expectation(description: "API response received")
        sdk.readUser(userKey) { user, error in
            XCTAssertNil(error)
            XCTAssertNotNil(user)
            
            XCTAssertEqual(user!.userKey, "userKey123")
            XCTAssertNotNil(user!.interests)
            XCTAssertNotNil(user!.blockedItems)
            XCTAssertNotNil(user!.consent)
            XCTAssertFalse(user!.consent!.gdpr)
            XCTAssertTrue(user!.optOut)
            XCTAssertEqual(Array(user!.customProperties.keys).sorted(), ["foo", "isCustom", "numberOfGems"].sorted())

            expectationResult.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanAddInterest() {
        let userKey = "userKey123"
        let expectationResult = expectation(description: "API Response received")
        sdk.addUserInterest("fishing", userKey: userKey) { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectationResult.fulfill()
        }

        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanOptOut() {
        let userKey = "userKey123"
        let expectationResult = expectation(description: "API response received")
        sdk.optOut(userKey) { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectationResult.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testCanRetargetUser() {
        let userKey = "userKey123"
        let brandId = 88205
        let segmentId = 1
        let expectationResult = expectation(description: "API Response received")
        sdk.retargetUser(userKey, brandId: brandId, segmentId: segmentId) { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectationResult.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
