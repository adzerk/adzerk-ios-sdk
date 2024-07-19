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
                completion(.failure(.errorPreparingRequest(nil)))
            }
            return
        }
        
        let request = URLRequest(url: url)
        transport.send(request,
                       decode: { data in
                        let decoder = AdzerkJSONDecoder()
                        return try decoder.decode(User.self, from: data)
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
                let encoder = AdzerkJSONEncoder()
                request.httpBody = try encoder.encode(properties)
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
        pixelRequest(endpoint: "optOut/i.gif", completion: completion)
    }
    
    public func addInterest(_ interest: String, completion: @escaping (Result<Void, AdzerkError>) -> Void) {
        pixelRequest(endpoint: "interest/i.gif", params: ["interest": interest], completion: completion)
    }
    
    public func retargetUser(advertiserId: Int, segment: Int, completion: @escaping (Result<Void, AdzerkError>) -> Void) {
        pixelRequest(endpoint: "rt/\(advertiserId)/\(segment)/i.gif", completion: completion)
    }
    
    private func pixelRequest(endpoint: String, params: [String: String] = [:], completion: @escaping (Result<Void, AdzerkError>) -> Void) {
        guard let userKey = keyStore.currentUserKey else {
            logger.log(.warning, message: "WARNING: No userKey specified, and none can be found in the configured key store.")
            transport.callbackQueue.async {
                completion(.failure(.missingUserKey))
            }
            return
        }
        
        guard let url = baseURL
            .appendingPathComponent(endpoint)
                .appendingQueryParameters(
                    params.merging(["userKey": userKey], uniquingKeysWith: { $1 })
                ) else {
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

#if swift(>=5.5)

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
//@MainActor
extension UserDB {
    public func readUser() async -> Result<User, AdzerkError> {
        guard let userKey = keyStore.currentUserKey else {
            logger.log(.warning, message: "WARNING: No userKey specified, and none can be found in the configured key store.")
            return .failure(.missingUserKey)
        }
        
        guard let url = baseURL.appendingPathComponent("read").appendingQueryParameters(["userKey": userKey]) else {
            logger.log(.warning, message: "WARNING: unable to construct readUser URL")
            return .failure(.errorPreparingRequest(nil))
        }
        
        let request = URLRequest(url: url)
        return await transport.send(request, decode: { data in
            let decoder = AdzerkJSONDecoder()
            return try decoder.decode(User.self, from: data)
        })
    }
    
    public func postProperties(_ properties: [String: AnyCodable]) async -> Result<Void, AdzerkError> {
        guard let userKey = keyStore.currentUserKey else {
            logger.log(.warning, message: "WARNING: No userKey specified, and none can be found in the configured key store.")
            return .failure(.missingUserKey)
        }
        
        guard let url = baseURL.appendingPathComponent("custom").appendingQueryParameters(["userKey": userKey]) else {
            logger.log(.warning, message: "WARNING: unable to construct readUser URL")
            return .failure(.errorPreparingRequest(nil))
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do {
            let encoder = AdzerkJSONEncoder()
            request.httpBody = try encoder.encode(properties)
            return await transport.send(request, decode: { _ in () }) // we don't care about the response
        } catch {
            return .failure(.errorPreparingRequest(error))
        }
    }
    
    public func optOut() async -> Result<Void, AdzerkError> {
        return await pixelRequest(endpoint: "optOut/i.gif")
    }
    
    public func addInterest(_ interest: String) async -> Result<Void, AdzerkError> {
        return await pixelRequest(endpoint: "interest/i.gif", params: ["interest": interest])
    }
    
    public func retargetUser(advertiserId: Int, segment: Int) async -> Result<Void, AdzerkError> {
        return await pixelRequest(endpoint: "rt/\(advertiserId)/\(segment)/i.gif")
    }
    
    private func pixelRequest(endpoint: String, params: [String: String] = [:]) async -> Result<Void, AdzerkError> {
        guard let userKey = keyStore.currentUserKey else {
            logger.log(.warning, message: "WARNING: No userKey specified, and none can be found in the configured key store.")
            return .failure(.missingUserKey)
        }
        
        guard let url = baseURL.appendingPathComponent(endpoint).appendingQueryParameters(
            params.merging(["userKey": userKey], uniquingKeysWith: { $1 })
        ) else {
            logger.log(.warning, message: "WARNING: unable to construct readUser URL")
            return .failure(.errorPreparingRequest(nil))
        }
        
        let request = URLRequest(url: url)
        return await transport.send(request, decode: { _ in () }) // we don't care about the response
    }
}

#endif
