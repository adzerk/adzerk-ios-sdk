import Foundation
import XCTest
@testable import AdzerkSDK

class PlacementRequestTests: XCTestCase {
    private var fakeKeyStore: UserKeyStore!
    
    private let networkId = 9792
    private let siteId = 306998
    
    override func setUp() {
        super.setUp()
        DecisionSDK.defaultNetworkId = networkId
        DecisionSDK.defaultSiteId = siteId
        
        fakeKeyStore = FakeKeyStore()
    }
    
    func testSimpleRequest() throws {
        let p = Placements.custom(divName: "div0", adTypes: [5])
        let request = PlacementRequest<StandardPlacement>.init(placements: [p], userKeyStore: fakeKeyStore)
        
        let data = try request.encodeBody()
        let actual = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let expected = [
          "enableBotFiltering" : false,
          "placements" : [
            [
              "siteId" : 306998,
              "adTypes" : [
                5
              ],
              "networkId" : 9792,
              "divName" : "div0"
            ]
          ]
        ] as [String : Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    func testRequestDefaultOptions() throws {
        let p = Placements.custom(divName: "div0", adTypes: [5])
        let reqOpts = PlacementRequest<StandardPlacement>.Options()
        let request = PlacementRequest<StandardPlacement>.init(placements: [p], options: reqOpts, userKeyStore: fakeKeyStore)
        
        let data = try request.encodeBody()
        let actual = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let expected = [
          "enableBotFiltering" : false,
          "placements" : [
            [
              "siteId" : 306998,
              "adTypes" : [
                5
              ],
              "networkId" : 9792,
              "divName" : "div0"
            ]
          ]
        ] as [String : Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    func testRequestOptions() throws {
        let p = Placements.custom(divName: "div0", adTypes: [5])
        let reqOpts = PlacementRequest<StandardPlacement>.Options(
            userKey: "testUserKey",
            keywords: ["testKeyword1", "testKeyword2"],
            blockedCreatives: [1, 2, 3],
            flightViewTimes: ["ua": [7937], "ana": [113, 627, 2479, 629]],
            url: "https://test.com",
            enableBotFiltering: true
        )
        let request = PlacementRequest<StandardPlacement>.init(placements: [p], options: reqOpts, userKeyStore: fakeKeyStore)
        
        let data = try request.encodeBody()
        let actual = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let expected = [
            "placements" : [
              [
                "siteId" : 306998,
                "adTypes" : [5],
                "networkId" : 9792,
                "divName" : "div0"
              ]
            ],
            "user": [
                "key": "testUserKey",
            ],
            "keywords": ["testKeyword1", "testKeyword2"],
            "blockedCreatives": [1, 2, 3],
            "flightViewTimes": ["ua": [7937], "ana": [113, 627, 2479, 629]],
            "enableBotFiltering": true,
        ] as [String : Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    func testRequestAdditionalOptions() throws {
        let p = Placements.custom(divName: "div0", adTypes: [5])
        var reqOpts = PlacementRequest<StandardPlacement>.Options()
        reqOpts.additionalOptions = [
            "includePricingData": .boolean(true)
        ]
        let request = PlacementRequest<StandardPlacement>.init(placements: [p], options: reqOpts, userKeyStore: fakeKeyStore)
        
        let data = try request.encodeBody()
        let actual = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let expected = [
            "placements" : [
              [
                "siteId" : 306998,
                "adTypes" : [5],
                "networkId" : 9792,
                "divName" : "div0"
              ]
            ],
            "enableBotFiltering" : false,
            "includePricingData" : true
        ] as [String : Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    func testRequestOptionsAndAdditionalOptions() throws {
        let p = Placements.custom(divName: "div0", adTypes: [5])
        var reqOpts = PlacementRequest<StandardPlacement>.Options(
            userKey: "testUserKey",
            keywords: ["testKeyword1", "testKeyword2"],
            blockedCreatives: [1, 2, 3],
            flightViewTimes: ["ua": [7937], "ana": [113, 627, 2479, 629]],
            url: "https://test.com",
            enableBotFiltering: true
        )
        
        reqOpts.additionalOptions = [
            "includePricingData": .boolean(true),
            "foo": .string("bar"),
        ]
        let request = PlacementRequest<StandardPlacement>.init(placements: [p], options: reqOpts, userKeyStore: fakeKeyStore)
        
        let data = try request.encodeBody()
        let actual = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let expected = [
            "placements" : [
              [
                "siteId" : 306998,
                "adTypes" : [5],
                "networkId" : 9792,
                "divName" : "div0"
              ]
            ],
            "user": [
                "key": "testUserKey",
            ],
            "keywords": ["testKeyword1", "testKeyword2"],
            "blockedCreatives": [1, 2, 3],
            "flightViewTimes": ["ua": [7937], "ana": [113, 627, 2479, 629]],
            "enableBotFiltering": true,
            "includePricingData" : true,
            "foo": "bar",
        ] as [String : Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    func testRequestOptionsOverAdditionalOptions() throws {
        let p = Placements.custom(divName: "div0", adTypes: [5])
        var reqOpts = PlacementRequest<StandardPlacement>.Options(
            userKey: "testUserKey",
            keywords: ["testKeyword1", "testKeyword2"],
            blockedCreatives: [1, 2, 3],
            flightViewTimes: ["ua": [7937], "ana": [113, 627, 2479, 629]],
            url: "https://test.com",
            enableBotFiltering: true
        )
        
        reqOpts.additionalOptions = [
            "user": .dictionary([
                "key": .string("no"),
            ]),
            "keywords": .array([.string("no")]),
            "blockedCreatives": .array([.int(0)]),
            "flightViewTimes": .dictionary(["no": .int(0)]),
            "enableBotFiltering": .boolean(false),
        ]
        let request = PlacementRequest<StandardPlacement>.init(placements: [p], options: reqOpts, userKeyStore: fakeKeyStore)
        
        let data = try request.encodeBody()
        let actual = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        let expected = [
            "placements" : [
              [
                "siteId" : 306998,
                "adTypes" : [5],
                "networkId" : 9792,
                "divName" : "div0"
              ]
            ],
            "user": [
                "key": "testUserKey",
            ],
            "keywords": ["testKeyword1", "testKeyword2"],
            "blockedCreatives": [1, 2, 3],
            "flightViewTimes": ["ua": [7937], "ana": [113, 627, 2479, 629]],
            "enableBotFiltering": true,
        ] as [String : Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    static var allTests = [
        ("testSimpleRequest", testSimpleRequest),
        ("testRequestDefaultOptions", testRequestDefaultOptions),
        ("testRequestOptions", testRequestOptions),
        ("testRequestAdditionalOptions", testRequestAdditionalOptions),
        ("testRequestOptionsAndAdditionalOptions", testRequestOptionsAndAdditionalOptions),
        ("testRequestOptionsOverAdditionalOptions", testRequestOptionsOverAdditionalOptions),
    ]
}
