//
//  NetworkTransport.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/16/20.
//

import Foundation

struct NetworkTransport: Transport {
    let session: URLSession
    let logger: Logger
    let callbackQueue: DispatchQueue
    let timeout: TimeInterval
    
    init(session: URLSession, logger: Logger, callbackQueue: DispatchQueue = .main, timeout: TimeInterval = 30) {
        self.session = session
        self.logger = logger
        self.callbackQueue = callbackQueue
        self.timeout = timeout
    }
    
    func send(_ request: URLRequest, completion: @escaping (Result<Data, AdzerkError>) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                self.dispatch(.failure(.networkingError(error)), to: completion)
                return
            }
            
            let data = data ?? Data()
            if let http = response as? HTTPURLResponse {
                logger.log(.debug, message: "Received HTTP \(http.statusCode) from \(request.url?.absoluteString ?? "")")
                if http.statusCode == 200 {
                    print("Response: \(String(data: data, encoding: .utf8) ?? "")")
                    self.dispatch(.success(data), to: completion)
                } else {
                    self.dispatch(.failure(.httpError(http.statusCode, data)), to: completion)
                }
            } else {
                self.dispatch(.failure(.invalidResponse), to: completion)
            }
        }
        
        logger.log(.debug, message: "HTTP \(request.httpMethod ?? "?") to \(request.url?.absoluteString ?? "?")")
        task.resume()
    }
    
    func send<T>(_ request: URLRequest, decode: @escaping (Data) throws -> T, completion: @escaping (Result<T, AdzerkError>) -> Void) {
        send(request) { dataResult in
            DispatchQueue.global().async {
                let result = mapResult(dataResult, map: decode)
                dispatch(result, to: completion)
            }
        }
    }
    
    /// Maps one Result type to another, catching decoding errors
    private func mapResult<T, K>(_ result: Result<T, AdzerkError>, map: (T) throws -> K) -> Result<K, AdzerkError> {
        switch result {
        case .success(let value):
            do {
                return .success(try map(value))
            } catch let d as DecodingError {
                return .failure(.decodingError(d))
            } catch {
                return .failure(.otherError(error))
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func dispatch<R, E>(_ result: Result<R, E>, to completion: @escaping (Result<R, E>) -> Void) {
        callbackQueue.async {
            completion(result)
        }
    }
}