//
//  Endpoint.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/4/20.
//

import Foundation

enum Endpoint: String {
    case decisionAPI = "/api/v2"
    case userDB = "/udb"
    
    private var path: String { rawValue }
    
    func baseURL(withHost host: String = AdzerkSDK.host) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        return components.url!
    }
}
