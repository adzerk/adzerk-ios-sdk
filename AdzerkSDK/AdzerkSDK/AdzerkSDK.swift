//
//  AdzerkSDK.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/10/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

let AdzerkBaseUrl = "https://engine.adzerk.net/api/v2"

public class AdzerkSDK {
    public static var defaultNetworkId: Int?
    public static var defaultSiteId: Int?
    
    public init() {
    }
    
    public func requestPlacementInDiv(div: String, adTypes: [Int], completion: (ADZPlacementResponse) -> ()) {
        if let placement = ADZPlacement(divName: div, adTypes: adTypes) {
            requestPlacement(placement, completion: completion)
        }
    }
    
    public func requestPlacement(placement: ADZPlacement, completion: (ADZPlacementResponse) -> ()) {
       requestPlacement([placement], completion: completion)
    }
    
    public func requestPlacement(placements: [ADZPlacement], completion: (ADZPlacementResponse) -> ()) {
        requestPlacement(placements, options: nil, completion: completion)
    }
 
    public func requestPlacement(placements: [ADZPlacement], options: ADZPlacementRequestOptions?, completion: (ADZPlacementResponse) -> ()) {
        if let request = buildPlacementRequest(placements, options: options) {
            let task = session.dataTaskWithRequest(request) {
                data, response, error in
                
                if let error = error {
                    completion(.Error(error))
                } else {
                    let http = response as! NSHTTPURLResponse
                    if http.statusCode == 200 {
                        completion(.Success(data))
                    } else {
                        let bodyString = (NSString(data: data, encoding: NSUTF8StringEncoding) as? String) ?? "<no body>"
                        completion(.BadRequest(http.statusCode, bodyString))
                    }
                }
                
            }
            task.resume()
        }
    }

    
    // MARK - private
    
    lazy var sessionConfiguration: NSURLSessionConfiguration = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        config.HTTPAdditionalHeaders = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        return config
    }()
    
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.sessionConfiguration)
    }()
    
    private var baseURL: NSURL {
        return NSURL(string: AdzerkBaseUrl)!
    }
    
    private let requestTimeout: NSTimeInterval = 15
    
    private func buildPlacementRequest(placements: [ADZPlacement], options: ADZPlacementRequestOptions?) -> NSURLRequest? {
        let url = baseURL
        var request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: requestTimeout)
        request.HTTPMethod = "POST"
        
        var body: [String: AnyObject] = [
            "placements": placements.map { $0.serialize() },
            "time": Int(NSDate().timeIntervalSince1970),
            "isMobile": true
        ]
        
        if let userKey = options?.userKey {
            body["user"] = ["key": userKey]
        }
        
        if let blockedCreatives = options?.blockedCreatives {
            body["blockedCreatives"] = blockedCreatives
        }
        
        if let flighViewTimes = options?.flightViewTimes {
            body["flightViewTimes"] = flighViewTimes
        }
        
        if let keywords = options?.keywords {
            body["keywords"] = keywords
        }
        
        if let referrer = options?.referrer {
            body["referrer"] = referrer
        }
        
        if let url = options?.url {
            body["url"] = url
        }
                
        var error: NSError?
        if let data = NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted, error: &error) {
            request.HTTPBody = data
            println("Posting JSON: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
            return request
        } else {
            println("Error building placement request: \(error)")
            return nil
        }
    }
}

public enum ADZPlacementResponse {
    case Success(NSData)
    case BadRequest(Int, String)
    case Error(NSError)
}