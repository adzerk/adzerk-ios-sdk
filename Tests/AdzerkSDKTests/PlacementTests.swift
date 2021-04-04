//
//  PlacementTests.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation
import XCTest
import AdzerkSDK

class PlacementTests: XCTestCase {
    
    struct CustomerProvidedProperties: Codable {
        let someKey: String
        struct Pet: Codable {
            let name: String
            let species: String
            let age: Int
        }
    }
    
    private let networkId = 9792
    private let siteId = 306998
    
    override func setUp() {
        super.setUp()
        DecisionSDK.defaultNetworkId = networkId
        DecisionSDK.defaultSiteId = siteId
    }
    
    func testSerializeStandardPlacement() throws {
        let placement = Placements.standard(divName: "someDiv", adTypes: [5])
        placement.zoneIds = [136961]
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let actual = try placement.bodyJson()!
        
        let expected = [
          "siteId" : 306998,
          "adTypes" : [
            5
          ],
          "networkId" : 9792,
          "divName" : "someDiv",
          "zoneIds" : [
            136961
          ]
        ] as [String: Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    func testPlacementCanValidate() throws {
        let placement = Placements.standard(divName: "someDiv", adTypes: [5])
        try placement.validate()
    }
    
    func testValidatePlacementWithEmptyAdTypesThrowsError() {
        let placement = Placements.standard(divName: "someDiv", adTypes: [])
        XCTAssertThrowsError(try placement.validate())
    }
    
    func testSerializeCustomPlacementWithProperties() throws {
        let placement = Placements.custom(divName: "someDiv", adTypes: [5])
        placement.properties = [
            "color": .string("blue"),
            "age": .int(57),
            "balance": .float(100.0),
            "powerUser": .boolean(true)
        ]
        placement.zoneIds = [136961]

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let actual = try placement.bodyJson()!

        let expected = [
          "adTypes" : [
            5
          ],
          "divName" : "someDiv",
          "networkId" : 9792,
          "properties" : [
            "age" : 57,
            "balance" : 100,
            "color" : "blue",
            "powerUser" : true
          ],
          "siteId" : 306998,
          "zoneIds" : [
            136961
          ]
        ] as [String: Any]
        XCAssertDictionaryEqual(expected, actual)
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

        let actual = try placement.bodyJson()!

        let expected = [
          "adTypes" : [
            5
          ],
          "divName" : "someDiv",
          "networkId" : 9792,
          "siteId" : 306998,
          "zoneIds" : [
            136961
          ],
          "age" : 57,
          "balance" : 100,
          "color" : "blue",
          "powerUser" : true
        ] as [String: Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    func testSerializeCustomPlacementWithBothPropertiesAndAdditionalOptions() throws {
        let placement = Placements.custom(divName: "someDiv", adTypes: [5])
        placement.properties = [
            "color": .string("blue"),
            "age": .int(57),
            "balance": .float(100.0),
            "powerUser": .boolean(true)
        ]
        placement.additionalOptions = [
            "color": .string("blue"),
            "age": .int(57),
            "balance": .float(100.0),
            "powerUser": .boolean(true)
        ]
        placement.zoneIds = [136961]

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let actual = try placement.bodyJson()!

        let expected = [
          "adTypes" : [
            5
          ],
          "divName" : "someDiv",
          "networkId" : 9792,
          "siteId" : 306998,
          "zoneIds" : [
            136961
          ],
          "age" : 57,
          "balance" : 100,
          "color" : "blue",
          "powerUser" : true,
          "properties" : [
            "age" : 57,
            "balance" : 100,
            "color" : "blue",
            "powerUser" : true
          ],
        ] as [String: Any]
        XCAssertDictionaryEqual(expected, actual)
    }
    
    static var allTests = [
        ("testSerializeStandardPlacement", testSerializeStandardPlacement),
        ("testSerializeCustomPlacementWithAdditionalOptions", testSerializeCustomPlacementWithAdditionalOptions)
    ]
}
