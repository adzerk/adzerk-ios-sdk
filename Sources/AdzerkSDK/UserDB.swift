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
                completion(.failure(.errorPreparingRequest))
            }
            return
        }
        
        transport.send(URLRequest(url: url), completion: completion)
    }
}
