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
    let callbackQueue: DispatchQueue = .main    
    let timeout: TimeInterval = 30
    
    func send<ResponseType: Decodable>(_ request: URLRequest, completion: @escaping (Result<ResponseType, AdzerkError>) -> Void) {
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
                        do {
                            let decoder = AdzerkJSONDecoder()
                            let response = try decoder.decode(ResponseType.self, from: data)
                            self.dispatch(.success(response), to: completion)
                        } catch let e as DecodingError {
                            self.dispatch(.failure(.decodingError(e)), to: completion)
                        }
                        catch { /* not possible */ }
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
    
    private func dispatch<R, E>(_ result: Result<R, E>, to completion: @escaping (Result<R, E>) -> Void) {
        callbackQueue.async {
            completion(result)
        }
    }
}
