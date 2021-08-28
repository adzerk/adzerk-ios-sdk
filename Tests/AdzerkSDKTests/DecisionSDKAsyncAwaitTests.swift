import XCTest
import AdzerkSDK

#if swift(>=5.5)

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
final class DecisionSDKAsyncAwaitTests: XCTestCase {
    private let networkId = 9792
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
        XCTAssertEqual(9792, DecisionSDK.defaultNetworkId)
    }
    
    func testDefaultSiteId() {
        XCTAssertEqual(306998, DecisionSDK.defaultSiteId)
    }
    
    func testCanRequestSimplePlacement() async {
        let result = await sdk.request(placement: Placements.standard(divName: "div1", adTypes: [5]))
        guard case .success = result else {
            XCTFail()
            return
        }
    }
    
    func testCanRequestCustomPlacementWithCustomProperties() async {
        let placement = Placements.custom(divName: "div1", adTypes: [5])
        placement.flightId = 699801
        placement.zoneIds = [136961]
        placement.properties = [
            "custom_key": .string("custom_value"),
            "foos": .array([.string("bar"), .string("baz"), .string("quux")]),
            "minions": .dictionary([
                "stuart": .int(12),
                "kevin": .int(13),
                "bob": .int(18)
            ])
        ]
        
        let result = await sdk.request(placement: placement)
        
        guard case .success(let response) = result else {
            XCTFail()
            return
        }
        
        guard let dec = response.decisions["div1"]?.first else {
            XCTFail("couldn't find div1 in response")
            return
        }
        
        XCTAssertTrue(dec.adId != nil, "Ad id was not set")
        XCTAssertTrue(dec.creativeId != nil, "Creative id was not set")
        XCTAssertTrue(dec.flightId != nil, "Flight id was not set")
        XCTAssertTrue(dec.campaignId != nil, "Campaign id was not set")
        XCTAssertTrue(dec.advertiserId != nil, "Advertiser id was not set")
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
    }
    
    func testRequestMultiplePlacementsReturnsDecisionsForEach() async {
        let placement1 = Placements.standard(divName: "div1", adTypes: [5])
        let placement2 = Placements.standard(divName: "div2", adTypes: [5])
        
        let result = await sdk.request(placements: [placement1, placement2])
        
        guard case .success(let response) = result else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(response.decisions["div1"])
        XCTAssertNotNil(response.decisions["div2"])
    }
    
    func testRequestPlacementsWithOptions() async {
        let placement = Placements.custom(divName: "div1", adTypes: [5])
        placement.adId = 1
        placement.campaignId = 1
        placement.flightId = 1
        placement.eventIds = [123]
        placement.properties = ["key": .string("val")]
        
        var options = placement.options()
        options.flightViewTimes = ["1234": [1512512, 1241212]]
        options.consent = .init(gdpr: true)
        options.blockedCreatives = [1,2,3]
        options.keywords = ["cheese", "apples", "wine"]
        
        let result = await sdk.request(placement: placement, options: options)
        
        guard case .success(let response) = result else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(response.decisions.keys.contains("div1"))
    }
    
    func testCanReadUser() async {
        let userKey = "ue1-e397eb5990"
        fakeKeyStore.save(userKey: userKey)
        
        let result = await sdk.userDB().readUser()
        
        guard case .success(let user) = result else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(user.key, "ue1-e397eb5990")
        XCTAssert(user.interests.contains("Sports"))
        XCTAssertEqual(user.blockedItems, [
            "advertisers": .array([]),
            "campaigns": .array([]),
            "creatives": .array([]),
            "flights": .array([]),
        ]
        )
    }
    
    func testCanPostUserProperties() async {
        let userKey = "ue1-e397eb5990"
        fakeKeyStore.save(userKey: userKey)
        
        let result = await sdk.userDB().postProperties([
            "favoriteFoods": .array([
                .string("apple"),
                .string("banana")
            ])
        ])
        
        guard case .success = result else {
            XCTFail()
            return
        }
    }
    
    func testCanOptOut() async {
        let userKey = UUID().uuidString
        fakeKeyStore.save(userKey: userKey)
        
        let result = await sdk.userDB().optOut()
        
        guard case .success = result else {
            XCTFail()
            return
        }
    }
    
    func testSavesUserKeyOnPlacementRequest() async {
        let fakeKeyStore = FakeKeyStore()
        let sdk = DecisionSDK(keyStore: fakeKeyStore)
        
        let placement = Placements.standard(divName: "div1", adTypes: [5])
        let result = await sdk.request(placement: placement)
        
        guard case .success = result else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(fakeKeyStore.currentUserKey, "User key was not set")
    }
    
    func testMultiWinnerRequest() async {
        let mwPlacement = Placements.standard(divName: "div1", adTypes: [5], count: 3)
        
        let result = await sdk.request(placement: mwPlacement)
        
        guard case .success(let r) = result else {
            XCTFail()
            return
        }
        
        let decisions = r.decisions["div1"]!
        XCTAssertGreaterThanOrEqual(decisions.count, 1)
    }
    
    func testCanAddUserInterest() async {
        let userKey = "ue1-e397eb5990"
        fakeKeyStore.save(userKey: userKey)
        
        let result = await sdk.userDB().addInterest("cats")
        
        guard case .success = result else {
            XCTFail()
            return
        }
    }
    
    func testCanRetargetUser() async {
        let userKey = "ue1-e397eb5990"
        fakeKeyStore.save(userKey: userKey)
        
        let result = await sdk.userDB().retargetUser(advertiserId: 1, segment: 1)
        
        guard case .success = result else {
            XCTFail()
            return
        }
    }
    
    func testSimpleFirePixel() async {
        let placement = Placements.standard(divName: "div1", adTypes: [4, 5], count: 3)
        let result = await sdk.request(placement: placement)
        
        guard case .success(let p) = result else {
            XCTFail()
            return
        }
        
        let decisions = p.decisions["div1"]!
        XCTAssertGreaterThanOrEqual(decisions.count, 1)
        let firstDecision = decisions[0]
        guard let clickUrl = firstDecision.clickUrl else {
            XCTFail()
            return
        }
        
        let pixelResult = await self.sdk.firePixel(url: clickUrl, additional: 1.25)
        
        guard case .success(let r) = pixelResult else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(r.statusCode, 302)
        XCTAssertEqual(r.location, "http://adzerk.com")
    }
}

#endif
