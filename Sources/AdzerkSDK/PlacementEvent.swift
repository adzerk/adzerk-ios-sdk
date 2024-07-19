//
//  PlacementEvent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/3/20.
//

import Foundation

/// Returns tracking URLs for any requested custom events.
public extension PlacementDecision {
    struct Event: Codable, Sendable {
        public let id: Int
        public let url: URL
    }
}
