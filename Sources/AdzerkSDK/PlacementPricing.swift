//
//  PlacementPricing.swift
//  AdzerkSDK
//

import Foundation

/// Pricing details for a decision. Only present when the request sets `includePricingData` to true.
public extension PlacementDecision {
    struct PricingData: Codable {
        public let price: Double?
        public let clearPrice: Double?

        /// Only present when a bid modifier applied to the impression.
        public let modifiedPrice: Double?

        /// Only present when the flight has a targetROAS configured.
        public let optimizedPrice: Double?

        public let eventMultiplier: Double?
        public let revenue: Double?
        public let rateType: Int?
        public let eCPM: Double?
    }
}
