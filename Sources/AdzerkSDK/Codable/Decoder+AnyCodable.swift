//
//  Decoder+AnyCodable.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/3/20.
//

import Foundation

extension Decoder {
    /// Decodes a dictionary of `AnyCodable` values using the provided CodingKeys type.
    /// Since `AnyCodable` may contain other containers, this may produce a tree of values.
    /// Use `DynamicCodingKey` to model all keys.
    func decodeAnyCodableTree<CK: CodingKey>(using: CK.Type, ignoringKeys: [CK] = []) throws -> [String: AnyCodable] {
        let container = try self.container(keyedBy: CK.self)
        var tree = [String: AnyCodable]()
        try container.allKeys.forEach { key in
            if ignoringKeys.map({ $0.stringValue }).contains(key.stringValue) {
                // this key is ignored, contine
                return
            }
            tree[key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
        }
        return tree
    }
}
