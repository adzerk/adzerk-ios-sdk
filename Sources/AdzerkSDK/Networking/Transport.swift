//
//  Transport.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/16/20.
//

import Foundation

public protocol Transport {
    var timeout: TimeInterval { get }
    var callbackQueue: DispatchQueue { get }
    
    func send<ResponseType: Decodable>(_ request: URLRequest, completion: @escaping (Result<ResponseType, AdzerkError>) -> Void)
}

public extension Transport {
    var timeout: TimeInterval { 30 }
    var callbackQueue: DispatchQueue { .main }
}
