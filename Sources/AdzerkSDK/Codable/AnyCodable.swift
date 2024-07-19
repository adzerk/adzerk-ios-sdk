//
//  AnyCodable.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 9/25/20.
//

import Foundation

/** Provides dynamic Codable support for arbitrary nested data structures.
    Supported types are `Int`, `String`, `Float`, `Bool`, as well as arrays and dictionaries of any of these.
 */
public indirect enum AnyCodable: Codable, Sendable {
    case null
    case int(Int)
    case string(String)
    case boolean(Bool)
    case float(Float)
    case array([AnyCodable])
    case dictionary([String: AnyCodable])
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                self = .null
            } else if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
            } else if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let boolValue = try? container.decode(Bool.self) {
                self = .boolean(boolValue)
            } else if let floatValue = try? container.decode(Float.self) {
                self = .float(floatValue)
            } else if let array = try? container.decode([AnyCodable].self) {
                self = .array(array)
            }
            else if let dictionary = try? container.decode([String: AnyCodable].self) {
                self = .dictionary(dictionary)
            } else {
                let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Tried to decode this value as Int, String, Bool, Float, Array, and Dictionary but was unsuccessful")
                throw DecodingError.typeMismatch(AnyCodable.self, context)
            }
        } else {
            fatalError("can't yet handle arrays or dictionary containers")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .int(let intValue): try container.encode(intValue)
        case .string(let stringValue): try container.encode(stringValue)
        case .boolean(let boolValue): try container.encode(boolValue)
        case .float(let floatValue): try container.encode(floatValue)
        case .array(let values): try container.encode(values)
        case .dictionary(let dictionary):
            try container.encode(dictionary)
        }
    }
}

extension AnyCodable: Equatable {
}
