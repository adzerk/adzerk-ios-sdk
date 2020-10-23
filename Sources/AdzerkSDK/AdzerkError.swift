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
    case errorPreparingRequest(Error?)
    
    /// Indicates a non-200 HTTP result was returned
    case httpError(Int, Data)
    
    /// An error occurred while parsing (decoding) the response)
    case decodingError(DecodingError)
    
    /// non HTTP response received
    case invalidResponse
    
    /// A UserDB request was made but no user key was present
    case missingUserKey
    
    // Indicates some unexpected error occurred
    case otherError(Error)
}

extension AdzerkError: CustomStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case .networkingError(let error):
            return "Networking Error: \(error.localizedDescription)"
            
        case .decodingError(let error):
            return "Decoding Error: \(error)"
            
        case .errorPreparingRequest(let error):
            return "Error Preparing Request: \(error?.localizedDescription ?? "-")"
            
        case .httpError(let status, _):
            return "HTTP \(status)"
            
        case .invalidResponse:
            return "Invalid Response"
            
        case .missingUserKey:
            return "No userKey was supplied"
        
        case .otherError(let error):
            return error.localizedDescription
        }
    }
    
    public var failureReason: String? {
        nil
    }
    
    public var errorDescription: String? {
        description
    }
    
}
