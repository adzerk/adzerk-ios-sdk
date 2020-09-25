import XCTest
@testable import AdzerkSDK

final class AdzerkSDKTests: XCTestCase {

    private let networkId = 23
    private let siteId = 306998
    private var sdk: AdzerkSDK!
    
    override func setUp() {
        super.setUp()
        AdzerkSDK.defaultNetworkId = networkId
        AdzerkSDK.defaultSiteId = siteId
        AdzerkSDK.logger.level = .debug
        sdk = AdzerkSDK()
    }

    func testDefaultNetworkId() {
        XCTAssertEqual(23, AdzerkSDK.defaultNetworkId)
    }
    
    func testDefaultSiteId() {
        XCTAssertEqual(306998, AdzerkSDK.defaultSiteId)
    }

    static var allTests = [
        ("testDefaultNetworkId", testDefaultNetworkId),
        ("testDefaultSiteId", testDefaultSiteId),
    ]
}
