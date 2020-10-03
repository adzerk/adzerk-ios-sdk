//
//  PlacementContent.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/3/20.
//

import Foundation

extension PlacementDecision {
    public struct Content: Codable {
        /// Indicates the type of content.
        /// Examples: `css`, `html`, `js, `js-external`, or `raw`
        public let type: ContentType?
        
        /// If the content uses a predefined template, this will be set to the name of the template
        public let template: String?
        
        /// Contains the template data to be used to build the content. This may contain arbitrary JSON data.
        public let data: [String: AnyCodable]?
        
        /// The rendered body of the content
        public let body: String?
    }
}

extension PlacementDecision.Content {
    public enum ContentType: Codable {
        case css
        case html
        case javascript
        case externalJavascript
        case raw
        case other(String)
        
        public var key: String {
            switch self {
            case .css: return "css"
            case .html: return "html"
            case .javascript: return "js"
            case .externalJavascript: return "js-external"
            case .raw: return "raw"
            case .other(let key): return key
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let key = try container.decode(String.self)
            switch key {
            case "css": self = .css
            case "html": self = .html
            case "js": self = .javascript
            case "jsExternal": self = .externalJavascript
            case "raw": self = .raw
            default: self = .other(key)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(key)
        }
    }
}

