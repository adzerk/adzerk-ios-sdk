//
//  AdzerkSDK.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/10/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation

/** The base URL to use for API requests. */
let AdzerkBaseUrl = "https://engine.adzerk.net/api/v2"

/** The primary class used to make requests against the API. */
public class AdzerkSDK {
    /** Provides storage for the default network ID to be used with all placement requests. If a value is present here, 
        each placement request does not need to provide it.  Any value in the placement request will override this value.
        Useful for the common case where the network ID is contstant for your application. */
    public static var defaultNetworkId: Int?
    
    /** Provides storage for the default site ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is contstant for your application. */
    public static var defaultSiteId: Int?
    
    /** The class used to save & retrieve the user DB key. */
    let keyStore: ADZUserKeyStore
    
    /** Initializes a new instance of `AdzerkSDK`.
        @param userKeyStore provide a value for this if you want to customize the way user keys are stored & retrieved. The default is `ADZKeychainUserKeyStore`.
    */
    public init(userKeyStore: ADZUserKeyStore = ADZKeychainUserKeyStore()) {
        self.keyStore = userKeyStore
    }
    
    /** Requests a single placement using only required parameters. This method is a convenience over the other placement request methods.
        @param div the div name to request
        @param adTypes an array of integers representing the ad types to request. The full list can be found at https://github.com/adzerk/adzerk-api/wiki/Ad-Types .
        @completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    public func requestPlacementInDiv(div: String, adTypes: [Int], completion: (ADZResponse) -> ()) {
        if let placement = ADZPlacement(divName: div, adTypes: adTypes) {
            requestPlacement(placement, completion: completion)
        }
    }

    /** Requests a single placement.
        @param placement the placement details to request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    public func requestPlacement(placement: ADZPlacement, completion: (ADZResponse) -> ()) {
       requestPlacement([placement], completion: completion)
    }

    /** Requests multiple placements.
        @param placements an array of placement details to request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    public func requestPlacement(placements: [ADZPlacement], completion: (ADZResponse) -> ()) {
        requestPlacement(placements, options: nil, completion: completion)
    }
 
    /** Requests multiple placements with additional options. The options can provide well-known or arbitrary parameters to th eoverall request.
        @param placements an array of placement details to request
        @param options an optional instance of `ADZPlacementRequestOptions` that provide top-level attributes to the request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    public func requestPlacement(placements: [ADZPlacement], options: ADZPlacementRequestOptions?, completion: (ADZResponse) -> ()) {
        if let request = buildPlacementRequest(placements, options: options) {
            let task = session.dataTaskWithRequest(request) {
                data, response, error in
                
                if let error = error {
                    completion(.Error(error))
                } else {
                    let http = response as! NSHTTPURLResponse
                    if http.statusCode == 200 {
                        if let resp = self.buildResponse(data) {
                            completion(ADZResponse.Success(resp))
                        } else {
                            let bodyString = (NSString(data: data, encoding: NSUTF8StringEncoding) as? String) ?? "<no body>"
                            completion(ADZResponse.BadResponse(bodyString))
                        }
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
        } else if let savedUserKey = keyStore.currentUserKey() {
            body["user"] = ["key": savedUserKey]
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
        
        if let url = options?.url {
            body["url"] = url
        }
        
        if let additionalOptions = options?.additionalOptions {
            for (key, val) in additionalOptions {
                body[key] = val
            }
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
    
    private func buildResponse(data: NSData) -> ADZPlacementResponse? {
        var error: NSError?
        if let responseDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [String: AnyObject] {
            
            saveUserKey(responseDictionary)
            
            return ADZPlacementResponse(dictionary: responseDictionary)
        } else {
            println("Couldn't parse response as JSON: \(error)")
            return nil
        }
    }
    
    private func saveUserKey(response: [String: AnyObject]) {
        if let userSection = response["user"] as? [String: AnyObject] {
            if let userKey = userSection["key"] as? String {
                keyStore.saveUserKey(userKey)
            }
        }
    }
}

