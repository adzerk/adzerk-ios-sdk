//
//  URL+Query.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/16/20.
//

import Foundation

extension URL {
    func appendingQueryParameters(_ params: [String: String]) -> URL! {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        components.queryItems?.append(contentsOf: params.map { k,v in
            URLQueryItem(name: k, value: v)
        })
        return components.url
    }
}
