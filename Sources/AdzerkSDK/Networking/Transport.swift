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
    
    /// Sends the request and calls back with the data from the response
    func send(_ request: URLRequest, completion: @escaping (Result<Data, AdzerkError>) -> Void)
    
    /// Sends the request and decodes the response using the provided block
    func send<T>(_ request: URLRequest, decode: @escaping (Data) throws -> T, completion: @escaping (Result<T, AdzerkError>) -> Void)
    
#if swift(>=5.5)
    
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func send(_ request: URLRequest) async -> Result<Data, AdzerkError>
    
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func send<T: Sendable>(_ request: URLRequest, decode: @escaping @Sendable (Data) throws -> T) async -> Result<T, AdzerkError>
    
#endif
}

public extension Transport {
    var timeout: TimeInterval { 30 }
    var callbackQueue: DispatchQueue { .main }
}
