import Foundation
import XCTest
@testable import AdzerkSDK

class PlacementResponseTests: XCTestCase {

    private func decode(_ json: String) throws -> PlacementResponse {
        try AdzerkJSONDecoder().decode(PlacementResponse.self, from: Data(json.utf8))
    }

    func testDecodesDimensions() throws {
        let response = try decode(Self.responseWithNewFields)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)

        XCTAssertEqual(decision.height, 250)
        XCTAssertEqual(decision.width, 300)
    }

    func testDecodesExternalMetadata() throws {
        let response = try decode(Self.responseWithNewFields)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)

        let metadata = try XCTUnwrap(decision.externalMetadata)
        XCTAssertEqual(metadata["campaignTag"], AnyCodable.string("summer-sale"))
        XCTAssertEqual(metadata["priority"], AnyCodable.int(3))
    }

    func testDecodesEcpmPartition() throws {
        let response = try decode(Self.responseWithNewFields)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)

        XCTAssertEqual(decision.ecpmPartition, "partition-a")
    }

    func testDecodesAdChain() throws {
        let response = try decode(Self.responseWithNewFields)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)
        let adChain = try XCTUnwrap(decision.adChain)

        XCTAssertEqual(adChain.count, 1)
        XCTAssertEqual(adChain[0].adId, 222)
        XCTAssertEqual(adChain[0].creativeId, 223)

        // nested decisions carry no divName of their own, so they inherit the placement's
        XCTAssertEqual(adChain[0].divName, "div1")
    }

    func testDecodesNumericMatchedPoints() throws {
        let response = try decode(Self.responseWithNewFields)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)
        let matchedPoints = try XCTUnwrap(decision.matchedPoints)

        XCTAssertEqual(matchedPoints.count, 2)
        XCTAssertEqual(matchedPoints[0].lat, 35.995063, accuracy: 0.000001)
        XCTAssertEqual(matchedPoints[0].lon, -78.908187, accuracy: 0.000001)
        XCTAssertEqual(matchedPoints[1].lat, 40.689188, accuracy: 0.000001)
        XCTAssertEqual(matchedPoints[1].lon, -74.044562, accuracy: 0.000001)
    }

    /// Responses used to carry lat/lon as strings, so those are still accepted.
    func testDecodesStringMatchedPoints() throws {
        let response = try decode(Self.responseWithStringMatchedPoints)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)
        let matchedPoints = try XCTUnwrap(decision.matchedPoints)

        XCTAssertEqual(matchedPoints.count, 1)
        XCTAssertEqual(matchedPoints[0].lat, 35.995063, accuracy: 0.000001)
        XCTAssertEqual(matchedPoints[0].lon, -78.908187, accuracy: 0.000001)
    }

    func testDecodesResponseWithoutOptionalFields() throws {
        let response = try decode(Self.minimalResponse)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)

        XCTAssertEqual(decision.adId, 111)
        XCTAssertNil(decision.height)
        XCTAssertNil(decision.width)
        XCTAssertNil(decision.externalMetadata)
        XCTAssertNil(decision.ecpmPartition)
        XCTAssertNil(decision.adChain)
        XCTAssertNil(decision.matchedPoints)
        XCTAssertNil(decision.pricing)
    }

    func testDecodesPricingData() throws {
        let response = try decode(Self.responseWithNewFields)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)
        let pricing = try XCTUnwrap(decision.pricing)

        XCTAssertEqual(pricing.price, 3.0)
        XCTAssertEqual(pricing.clearPrice, 2.0)
        XCTAssertEqual(pricing.modifiedPrice, 1.5)
        XCTAssertEqual(pricing.optimizedPrice, 2.25)
        XCTAssertEqual(pricing.eventMultiplier, 1.1)
        XCTAssertEqual(pricing.revenue, 0.003)
        XCTAssertEqual(pricing.rateType, 2)
        XCTAssertEqual(pricing.eCPM, 3.0)
    }

    /// Individual pricing fields are only sent when they apply to the matched impression.
    func testDecodesPartialPricingData() throws {
        let response = try decode(Self.responseWithPartialPricing)
        let decision = try XCTUnwrap(response.decisions["div1"]?.first)
        let pricing = try XCTUnwrap(decision.pricing)

        XCTAssertEqual(pricing.price, 3.0)
        XCTAssertEqual(pricing.clearPrice, 2.0)
        XCTAssertNil(pricing.modifiedPrice)
        XCTAssertNil(pricing.optimizedPrice)
        XCTAssertNil(pricing.eventMultiplier)
    }

    func testEncodesMatchedPointsAsNumbers() throws {
        let point = GeoPoint(lat: 35.995063, lon: -78.908187)
        let data = try JSONEncoder().encode(point)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(json["lat"] as? Double, 35.995063)
        XCTAssertEqual(json["lon"] as? Double, -78.908187)
    }

    private static let responseWithNewFields = """
    {
      "user": { "key": "abc-123" },
      "decisions": {
        "div1": {
          "adId": 111,
          "creativeId": 112,
          "flightId": 113,
          "campaignId": 114,
          "advertiserId": 115,
          "clickUrl": "https://e-9792.adzerk.net/r?e=click",
          "impressionUrl": "https://e-9792.adzerk.net/i.gif",
          "height": 250,
          "width": 300,
          "ecpmPartition": "partition-a",
          "externalMetadata": {
            "campaignTag": "summer-sale",
            "priority": 3
          },
          "contents": [ { "type": "html", "template": "image", "body": "<div></div>" } ],
          "events": [],
          "adChain": [
            {
              "adId": 222,
              "creativeId": 223,
              "contents": [],
              "events": []
            }
          ],
          "matchedPoints": [
            { "lat": 35.995063, "lon": -78.908187 },
            { "lat": 40.689188, "lon": -74.044562 }
          ],
          "pricing": {
            "price": 3.0,
            "clearPrice": 2.0,
            "modifiedPrice": 1.5,
            "optimizedPrice": 2.25,
            "eventMultiplier": 1.1,
            "revenue": 0.003,
            "rateType": 2,
            "eCPM": 3.0
          }
        }
      }
    }
    """

    private static let responseWithPartialPricing = """
    {
      "decisions": {
        "div1": {
          "adId": 111,
          "contents": [],
          "events": [],
          "pricing": { "price": 3.0, "clearPrice": 2.0, "revenue": 0.003, "rateType": 2, "eCPM": 3.0 }
        }
      }
    }
    """

    private static let responseWithStringMatchedPoints = """
    {
      "decisions": {
        "div1": {
          "adId": 111,
          "contents": [],
          "events": [],
          "matchedPoints": [ { "lat": "35.995063", "lon": "-78.908187" } ]
        }
      }
    }
    """

    private static let minimalResponse = """
    {
      "decisions": {
        "div1": {
          "adId": 111,
          "contents": [],
          "events": []
        }
      }
    }
    """
}
