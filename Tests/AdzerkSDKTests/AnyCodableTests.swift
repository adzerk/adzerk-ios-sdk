//
//  AnyCodableTests.swift
//  AdzerkSDKTests
//
//  Created by Ben Scheirman on 9/25/20.
//

import XCTest
@testable import AdzerkSDK

class AnyCodableTests: XCTestCase {
    
    func testEncodeInt() throws {
        try assertOptionEquals(.int(87), "87")
    }
    
    func testEncodeString() throws {
        try assertOptionEquals(.string("lasso"), "\"lasso\"")
    }
    
    func testEncodeBoolean() throws {
        try assertOptionEquals(.boolean(true), "true")
        try assertOptionEquals(.boolean(false), "false")
    }
    
    func testEncodeFloat() throws {
        try assertOptionEquals(.float(65.5), "65.5")
    }
    
    func testEncodeArray() throws {
        try assertOptionEquals(.array([.int(55), .int(66)]),
            """
            [
              55,
              66
            ]
            """
        )
        
        try assertOptionEquals(.array([.boolean(true), .boolean(false)]),
            """
            [
              true,
              false
            ]
            """
        )
        
        try assertOptionEquals(.array([.string("coffee"), .string("tea")]),
            """
            [
              "coffee",
              "tea"
            ]
            """
        )
        
        try assertOptionEquals(.array([]), "[]", formatted: false)
    }
    
    func testEncodeDictionary() throws {
        try assertOptionEquals(
            .dictionary([
                "name": .string("ben"),
                "score": .int(994),
            ]),
            """
            {
              "name" : "ben",
              "score" : 994
            }
            """
            )
        
        try assertOptionEquals(
            .dictionary([
                "tags": .array([.string("swift"), .string("objc"), .string("javascript")])
            ])
            ,
            """
            {
              "tags" : [
                "swift",
                "objc",
                "javascript"
              ]
            }
            """)
    }
    
    func testDecodeInt() throws {
        try assertDecodeOption("972", .int(972))
    }
    
    func testDecodeString() throws {
        try assertDecodeOption("\"cucumber\"", .string("cucumber"))
    }
    
    func testDecodeBool() throws {
        try assertDecodeOption("true", .boolean(true))
    }
    
    func testDecodeFloat() throws {
        try assertDecodeOption("98.7", .float(98.7))
    }
    
    func testDecodeArray() throws {
        try assertDecodeOption("[1, 2, 3]", .array([.int(1), .int(2), .int(3)]))
    }
    
    func testDecodeDictionary() throws {
        try assertDecodeOption(
            """
            {
                "languages": ["ruby", "swift"],
                "level": "silver",
                "score": 35,
                "character": {
                    "firstName": "George",
                    "lastName": "Costanza"
                }
            }
            """
            ,
            .dictionary(
                [
                    "languages": .array([.string("ruby"), .string("swift")]),
                    "level": .string("silver"),
                    "score": .int(35),
                    "character": .dictionary([
                        "firstName": .string("George"),
                        "lastName": .string("Costanza")
                    ])
                ]
            )
            )
    }
    
    func assertOptionEquals(_ option: AnyCodable, _ json: String, formatted: Bool = true, file: StaticString = #file, line: UInt = #line) throws {
        let actual = try encode(option, formatted: formatted)
        XCTAssertEqual(json, actual, file: file, line: line)
    }
    
    func assertDecodeOption(_ json: String, _ expectedOption: AnyCodable, file: StaticString = #file, line: UInt = #line) throws {
        let actual = try decode(json)
        XCTAssertEqual(actual, expectedOption)
    }
    
    private func encode(_ option: AnyCodable, formatted: Bool) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        if formatted {
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        }
        let data = try encoder.encode(option)
        return String(data: data, encoding: .utf8) ?? ""
    }

    private func decode(_ json: String) throws -> AnyCodable {
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        return try decoder.decode(AnyCodable.self, from: data)
    }
}
