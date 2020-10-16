//
//  AdzerkError.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 10/4/20.
//

import Foundation

public enum AdzerkError: Error {
    /// Indicates a networking or connection error occurred
    case networkingError(Error)
    
    /// An error preparing the request, for instance, encoding the request body.
    case errorPreparingRequest
    
    /// Indicates a non-200 HTTP result was returned
    case httpError(Int, Data)
    
    case decodingError(DecodingError)
    
    // non HTTP response received
    case invalidResponse
    
    case missingUserKey
}

extension AdzerkError: CustomStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case .networkingError(let error):
            return "Networking Error: \(error.localizedDescription)"
            
        case .decodingError(let error):
            return "Decoding Error: \(error)"
            
        case .errorPreparingRequest:
            return "Error Preparing Request"
            
        case .httpError(let status, _):
            return "HTTP \(status)"
            
        case .invalidResponse:
            return "Invalid Response"
            
        case .missingUserKey:
            return "No userKey was supplied"
        }
    }
    
    public var failureReason: String? {
        nil
    }
    
    public var errorDescription: String? {
        description
    }
    
}
