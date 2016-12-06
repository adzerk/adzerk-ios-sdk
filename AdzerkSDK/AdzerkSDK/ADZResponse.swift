//
//  ADZResponse.swift
//  AdzerkSDK
//
//  Created by ben on 9/1/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/** Models the various types of responses you can receive from the API. */
public enum ADZResponse {
    /** Indicates a successful response. Includes the placements requested. */
    case success(ADZPlacementResponse)
    
    /** Indicates something was wrong with the request. Includes the HTTP status code and the response body. */
    case badRequest(Int, String)
    
    /** Indicates the response was not recognized (valid JSON). Includes the response body. */
    case badResponse(String)
    
    /** Indicates that the request was not completed. This can happen due to lack of network connectivity, redirect loops, timeouts, and other factors. */
    case error(Error)
}
