import XCTest
@testable import AdzerkSDK

final class DecisionSDKTests: XCTestCase {

    private let networkId = 23
    private let siteId = 306998
    private var sdk: DecisionSDK!
    private var fakeKeyStore: UserKeyStore!
    
    override func setUp() {
        super.setUp()
        DecisionSDK.defaultNetworkId = networkId
        DecisionSDK.defaultSiteId = siteId
        DecisionSDK.logger.level = .debug
        fakeKeyStore = FakeKeyStore()
        
        sdk = DecisionSDK(keyStore: fakeKeyStore)
    }

    func testDefaultNetworkId() {
        XCTAssertEqual(23, DecisionSDK.defaultNetworkId)
    }
    
    func testDefaultSiteId() {
        XCTAssertEqual(306998, DecisionSDK.defaultSiteId)
    }
    
    func testCallsBackOnMainQueue() {
        let expectationResult = expectation(description: "API response received")
        sdk.request(placement: Placements.standard(divName: "div1", adTypes: [5])) { response in
            XCTAssert(Thread.isMainThread, "Called back on background thread")
            expectationResult.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testCallsBackOnProvidedQueue() {
        let myQueue = DispatchQueue.global(qos: .background)
        let sdkWithQueue = DecisionSDK(keyStore: fakeKeyStore, queue: myQueue)
        let expectation = self.expectation(description: "API response received")
        sdkWithQueue.request(placement: Placements.standard(divName: "div1", adTypes: [5])) { response in
            XCTAssertFalse(Thread.isMainThread, "Called back on background thread")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testCanRequestSimplePlacement() {
        let expectationResult = expectation(description: "API response received")
        sdk.request(placement: Placements.standard(divName: "div1", adTypes: [5]), completion: completionCheckingSuccessfulResponse(expectation: expectationResult))
        waitForExpectations(timeout: 3.0, handler: nil)
     }
    
    func testCanRequestCustomPlacementwithAdditionalOptions() {
        let placement = Placements.custom(divName: "div1", adTypes: [5])
        placement.flightId = 699801
        placement.zoneIds = [136961]
        placement.additionalOptions = [
            "custom_key": .string("custom_value"),
            "foos": .array([.string("bar"), .string("baz"), .string("quux")]),
            "minions": .dictionary([
                "stuart": .int(12),
                "kevin": .int(13),
                "bob": .int(18)
            ])
        ]
        
        let expectation = self.expectation(description: "API response received")
        sdk.request(placement: placement, completion: completionExtractingSuccessfulValue(expectation: expectation) { response in
            if let dec = response.decisions["div1"] {
                XCTAssertTrue(dec.adId != nil, "Ad id was not set")
                XCTAssertTrue(dec.creativeId != nil, "Creative id was not set")
                XCTAssertTrue(dec.flightId != nil, "Flight id was not set")
                XCTAssertTrue(dec.campaignId != nil, "Campaign id was not set")
                XCTAssertTrue(dec.clickUrl != nil, "Click URL was not set")
                
                XCTAssertEqual(dec.contents.count, 1, "Should have had 1 item in contents")
                do {
                    let content = try XCTUnwrap(dec.contents.first)
                    XCTAssertEqual(content.type, .html, "content type should be html")
                    
                    XCTAssertEqual(content.template, "image", "content template should be image")
                    XCTAssertNotNil(content.data, "content data should have been set")
                    XCTAssertNotNil(content.body, "content body should have been set")
                    XCTAssertEqual(dec.events.count, 0, "events should have been an empty array")
                } catch {
                    XCTFail(error.localizedDescription)
                }

            } else {
                XCTFail("couldn't find div1 in response")
            }
        })
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testRequestMultiplePlacementsReturnsDecisionsForEach() {
        let placement1 = Placements.standard(divName: "div1", adTypes: [5])
        let placement2 = Placements.standard(divName: "div2", adTypes: [5])
        let exp = expectation(description: "API Response Received")
        sdk.request(placements: [placement1, placement2]) { result in
            exp.fulfill()
            do {
                let response = try result.get()
                XCTAssertNotNil(response.decisions["div1"])
                XCTAssertNotNil(response.decisions["div2"])
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequestPlacementsWithOptions() {
        let placement = Placements.custom(divName: "div1", adTypes: [5])
        placement.adId = 1
        placement.campaignId = 1
        placement.flightId = 1
        placement.eventIds = [123]
        placement.additionalOptions = ["key": .string("val")]
        
        var options = placement.options()
        options.flightViewTimes = ["1234": [1512512, 1241212]]
        options.consent = .init(gdpr: true)
        options.blockedCreatives = [1,2,3]
        options.keywords = ["cheese", "apples", "wine"]
        
        let exp = expectation(description: "API response received")
        sdk.request(placement: placement, options: options, completion: completionExtractingSuccessfulValue(expectation: exp, validationHandler: { response in
            XCTAssertNotNil(response.decisions.keys.contains("div1"))
        }))
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCanReadUser() {
        XCTFail()
//        let userKey = "userKey123"
//        let exp = expectation(description: "API Response Received")
//        sdk.userDB().readUser(userKey) { result in
//            let response = result.getOrFail()
//        }
//        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // Assert that the API response is called and returns .Success
    // response data is ignored
    func completionCheckingSuccessfulResponse(expectation: XCTestExpectation) -> (Result<PlacementResponse, AdzerkError>) -> () {
        completionExtractingSuccessfulValue(expectation: expectation) { r in
            print(r)
        }
    }

    // Assert that the API response is called. Calls the validationHandler in the case of .success for callers to
    // validate the response structure.
    func completionExtractingSuccessfulValue(expectation: XCTestExpectation, validationHandler: ((PlacementResponse) -> Void)? = nil) -> (Result<PlacementResponse, AdzerkError>) -> Void {
        return { result in
            switch result {
            case .success(let placementResponse):
                validationHandler?(placementResponse)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
    }

    static var allTests = [
        ("testDefaultNetworkId", testDefaultNetworkId),
        ("testDefaultSiteId", testDefaultSiteId),
    ]
}

extension Result {
    func getOrFail(message: String? = nil, file: StaticString = #file, line: UInt = #line) -> Success {
        do {
            return try get()
        } catch {
            XCTFail(message ?? "Result was not successful: \(error)")
        }
    }
}
