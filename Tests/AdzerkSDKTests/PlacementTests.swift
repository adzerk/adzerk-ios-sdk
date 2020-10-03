//
//  PlacementTests.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation
import XCTest
@testable import AdzerkSDK

class PlacementTests: XCTestCase {
    
    struct CustomerProvidedProperties: Codable {
        let someKey: String
        struct Pet: Codable {
            let name: String
            let species: String
            let age: Int
        }
    }
    
    private let networkId = 23
    private let siteId = 306998
    
    override func setUp() {
        super.setUp()
        AdzerkSDK.defaultNetworkId = networkId
        AdzerkSDK.defaultSiteId = siteId
    }

    
    func testSerializeStandardPlacement() throws {
        let placement = Placements.standard(divName: "someDiv", adTypes: [5])
        placement.zoneIds = [136961]
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(placement)
        let actual = String(data: data, encoding: .utf8)!
        
        let expected = """
        {
          "siteId" : 306998,
          "adTypes" : [
            5
          ],
          "networkId" : 23,
          "divName" : "someDiv",
          "zoneIds" : [
            136961
          ]
        }
        """
        XCTAssertEqual(expected, actual)
    }
    
    func testSerializeCustomPlacementWithAdditionalOptions() throws {
        let placement = Placements.custom(divName: "someDiv", adTypes: [5])
        placement.additionalOptions = [
            "color": .string("blue"),
            "age": .int(57),
            "balance": .float(100.0),
            "powerUser": .boolean(true)
        ]
        placement.zoneIds = [136961]

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(placement)
        let actual = String(data: data, encoding: .utf8)!

        let expected = """
        {
          "additionalOptions" : {
            "age" : 57,
            "balance" : 100,
            "color" : "blue",
            "powerUser" : true
          },
          "adTypes" : [
            5
          ],
          "divName" : "someDiv",
          "networkId" : 23,
          "siteId" : 306998,
          "zoneIds" : [
            136961
          ]
        }
        """
        XCTAssertEqual(actual, expected)
    }
    
    static var allTests = [
        ("testSerializeStandardPlacement", testSerializeStandardPlacement),
        ("testSerializeCustomPlacementWithAdditionalOptions", testSerializeCustomPlacementWithAdditionalOptions)
    ]
}
