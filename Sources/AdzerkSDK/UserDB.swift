//
//  UserDB.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/16/20.
//

import Foundation

public class UserDB {
    private let baseURL: URL
    private let networkId: Int
    private let keyStore: UserKeyStore
    private let transport : Transport
    private let logger: Logger
    private let decoder = AdzerkJSONDecoder()
    private let encoder = AdzerkJSONEncoder()
    
    public init(host: String, networkId: Int, keyStore: UserKeyStore, logger: Logger, transport: Transport) {
        baseURL = Endpoint.userDB.baseURL(withHost: host).appendingPathComponent("\(networkId)/")
        self.networkId = networkId
        self.keyStore = keyStore
        self.logger = logger
        self.transport = transport
    }
    
    public func readUser(completion: @escaping (Result<User, AdzerkError>) -> Void) {
        guard let userKey = keyStore.currentUserKey else {
            logger.log(.warning, message: "WARNING: No userKey specified, and none can be found in the configured key store.")
            transport.callbackQueue.async {
                completion(.failure(.missingUserKey))
            }
            return
        }
        
        guard let url = baseURL
            .appendingPathComponent("read")
                .appendingQueryParameters(["userKey": userKey]) else {
            logger.log(.warning, message: "WARNING: unable to construct readUser URL")
            transport.callbackQueue.async {
                completion(.failure(.errorPreparingRequest(nil)))
            }
            return
        }
        
        let request = URLRequest(url: url)
        transport.send(request,
                       decode: { data in
                        try self.decoder.decode(User.self, from: data)
                       },
                       completion: completion)
    }
    
    public func postProperties(_ properties: [String: AnyCodable], completion: @escaping (Result<Void, AdzerkError>) -> Void) {
        guard let userKey = keyStore.currentUserKey else {
            logger.log(.warning, message: "WARNING: No userKey specified, and none can be found in the configured key store.")
            transport.callbackQueue.async {
                completion(.failure(.missingUserKey))
            }
            return
        }
        
        guard let url = baseURL
            .appendingPathComponent("custom")
                .appendingQueryParameters(["userKey": userKey]) else {
            logger.log(.warning, message: "WARNING: unable to construct readUser URL")
            transport.callbackQueue.async {
                completion(.failure(.errorPreparingRequest(nil)))
            }
            return
        }
        
        DispatchQueue.global().async {
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            do {
                request.httpBody = try self.encoder.encode(properties)
                self.transport.send(request,
                               decode: { _ in () }, // we don't care about the response
                               completion: completion)
            } catch {
                self.transport.callbackQueue.async {
                    completion(.failure(.errorPreparingRequest(error)))
                }
            }
        }
    }
    
    public func optOut(completion: @escaping (Result<Void, AdzerkError>) -> Void) {
        guard let userKey = keyStore.currentUserKey else {
            logger.log(.warning, message: "WARNING: No userKey specified, and none can be found in the configured key store.")
            transport.callbackQueue.async {
                completion(.failure(.missingUserKey))
            }
            return
        }
        
        guard let url = baseURL
            .appendingPathComponent("optOut/i.gif")
                .appendingQueryParameters(["userKey": userKey]) else {
            logger.log(.warning, message: "WARNING: unable to construct readUser URL")
            transport.callbackQueue.async {
                completion(.failure(.errorPreparingRequest(nil)))
            }
            return
        }
        
        let request = URLRequest(url: url)
        transport.send(request,
                       decode: { _ in () }, // we don't care about the response
                       completion: completion)
    }
}
