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
let AdzerkUDBBaseUrl = "http://engine.adzerk.net/udb"

public typealias ADZResponseSuccessCallback = (ADZPlacementResponse) -> ()
public typealias ADZResponseFailureCallback = (Int?, String?, NSError?) -> ()
public typealias ADZResponseCallback = (Bool, NSError?) -> ()
public typealias ADZUserDBUserResponseCallback = (ADZUser?, NSError?) -> ()

/** The primary class used to make requests against the API. */
@objc public class AdzerkSDK : NSObject {
    
    private static var _defaultNetworkId: Int?
    /** Provides storage for the default network ID to be used with all placement requests. If a value is present here,
        each placement request does not need to provide it.  Any value in the placement request will override this value.
        Useful for the common case where the network ID is contstant for your application. */
    public class var defaultNetworkId: Int? {
        get { return _defaultNetworkId }
        set { _defaultNetworkId = newValue }
    }
    
    private static var _defaultSiteId: Int?
    /** Provides storage for the default site ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is contstant for your application. */
    public class var defaultSiteId: Int? {
        get { return _defaultSiteId }
        set { _defaultSiteId = newValue }
    }
    
    /** Setter for defaultNetworkId. Provided for Objective-C compatibility. */
    public class func setDefaultNetworkId(networkId: Int) {
        defaultNetworkId = networkId
    }
    
    /** Setter for defaultSiteId. Provided for Objective-C compatibility. */
    public class func setDefaultSiteId(siteId: Int) {
        defaultSiteId = siteId
    }
    
    /** The class used to save & retrieve the user DB key. */
    let keyStore: ADZUserKeyStore
    
    /** Initializes a new instance of `AdzerkSDK` with a keychain-based userKeyStore.
    */
    public convenience override init() {
        self.init(userKeyStore: ADZKeychainUserKeyStore())
    }
    
    /** Initializes a new instance of `AdzerkSDK`.
        @param userKeyStore provide a value for this if you want to customize the way user keys are stored & retrieved. The default is `ADZKeychainUserKeyStore`.
    */
    public init(userKeyStore: ADZUserKeyStore) {
        self.keyStore = userKeyStore
    }
    
    /** Requests placements with explicit success and failure callbacks. Provided for Objective-C compatibility.
        See `requestPlacements:options:completion` for complete documentation.
    */
    public func requestPlacements(placements: [ADZPlacement], options: ADZPlacementRequestOptions? = nil,
        success: (ADZPlacementResponse) -> (),
        failure: (NSNumber?, NSString?, NSError?) -> ()) {
        
        requestPlacements(placements, options: options) { response in
            switch response {
            case .Success(let placementResponse):
                success(placementResponse)
            case .BadRequest(let statusCode, let body):
                failure(statusCode, body, nil)
            case .BadResponse(let body):
                failure(nil, body, nil)
            case .Error(let error):
                failure(nil, nil, error)
            }
        }
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
       requestPlacements([placement], completion: completion)
    }

    /** Requests multiple placements.
        @param placements an array of placement details to request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    public func requestPlacements(placements: [ADZPlacement], completion: (ADZResponse) -> ()) {
        requestPlacements(placements, options: nil, completion: completion)
    }
 
    /** Requests multiple placements with additional options. The options can provide well-known or arbitrary parameters to th eoverall request.
        @param placements an array of placement details to request
        @param options an optional instance of `ADZPlacementRequestOptions` that provide top-level attributes to the request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    public func requestPlacements(placements: [ADZPlacement], options: ADZPlacementRequestOptions?, completion: (ADZResponse) -> ()) {
        if let request = buildPlacementRequest(placements, options: options) {
            let task = session.dataTaskWithRequest(request) {
                data, response, error in
                
                if let error = error {
                    completion(.Error(error))
                } else {
                    let http = response as! NSHTTPURLResponse
                    if http.statusCode == 200 {
                        if let resp = self.buildPlacementResponse(data!) {
                            completion(ADZResponse.Success(resp))
                        } else {
                            let bodyString = (NSString(data: data!, encoding: NSUTF8StringEncoding) as? String) ?? "<no body>"
                            completion(ADZResponse.BadResponse(bodyString))
                        }
                    } else {
                        let bodyString = (NSString(data: data!, encoding: NSUTF8StringEncoding) as? String) ?? "<no body>"
                        completion(.BadRequest(http.statusCode, bodyString))
                    }
                }
                
            }
            task.resume()
        }
    }
    
    // MARK - UserDB endpoints
    
    /** Posts custom properties for a user.
        @param userKey a string identifying the user. If nil, the value will be fetched from the configured UserKeyStore.
        @param properties a JSON serializable dictionary of properties to send to the UserDB endpoint.
        @param callback a simple callback block indicating success or failure, along with an optional `NSError`.
    */
    public func postUserProperties(userKey: String?, properties: [String : AnyObject], callback: ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            print("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
    
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            print("WARNING: No userKey specified, and none can be found in the configured key store.")
            callback(false, nil)
            return
        }
        
        postUserProperties(networkId, userKey: actualUserKey, properties: properties, callback: callback)
    }

    // MARK - UserDB endpoints
    
    /** Posts custom properties for a user.
    @param networkId the networkId for this request
    @param userKey a string identifying the user
    @param properties a JSON serializable dictionary of properties to send to the UserDB endpoint.
    @param callback a simple callback block indicating success or failure, along with an optional `NSError`.
    */
    public func postUserProperties(networkId: Int, userKey: String, properties: [String : AnyObject], callback: ADZResponseCallback) {
        guard let url = NSURL(string: "\(AdzerkUDBBaseUrl)/\(networkId)/custom?userKey=\(userKey)") else {
            print("WARNING: Could not build URL with provided params. Network ID: \(networkId), userKey: \(userKey)")
            callback(false, nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        request.HTTPMethod = "POST"
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(properties, options: NSJSONWritingOptions.PrettyPrinted)
            request.HTTPBody = data
            let task = session.dataTaskWithRequest(request) {
                (data, response, error) in
                if error == nil {
                    let http = response as! NSHTTPURLResponse
                    if http.statusCode == 200 {
                        callback(true, nil)
                    } else {
                        print("Received HTTP \(http.statusCode) from \(request.URL)")
                        callback(false, nil)
                    }
                } else {
                    callback(false, error)
                }
            }
            task.resume()
        }
        catch let exc as NSException {
            print("WARNING: Could not serialize the submitted properties into JSON: \(properties).")
            print("\(exc.name) -> \(exc.reason)")
            callback(false, nil)
        }
        catch let error as NSError {
            callback(false, error)
        }
    }
    
    /** Returns the UserDB data for a given user.
    @param userKey a string identifying the user
    @param callback a simple callback block indicating success or failure, along with an optional `NSError`.
    */
    public func readUser(userKey: String?, callback: ADZUserDBUserResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            print("WARNING: No defaultNetworkId set.")
            callback(nil, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            print("WARNING: No userKey specified, and none can be found in the configured key store.")
            callback(nil, nil)
            return
        }
        
        readUser(networkId, userKey: actualUserKey, callback: callback)
    }
    
    /** Returns the UserDB data for a given user.
    @param networkId the networkId to use for this request
    @param userKey a string identifying the user
    @param callback a simple callback block indicating success or failure, along with an optional `NSError`.
    */
    public func readUser(networkId: Int, userKey: String, callback: ADZUserDBUserResponseCallback) {
        guard let url = NSURL(string: "\(AdzerkUDBBaseUrl)/\(networkId)/read?userKey=\(userKey)") else {
            print("WARNING: Could not build URL with provided params. Network ID: \(networkId), userKey: \(userKey)")
            callback(nil, nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: url)

        // Fails with HTTP 500 if the default application/json is specified.
        request.allHTTPHeaderFields = [
            "Content-Type" : ""
        ]
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) in
            if error == nil {
                let http = response as! NSHTTPURLResponse
                if http.statusCode == 200 {
                    do {
                        if let userDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: [.AllowFragments]) as? [String: AnyObject] {
                            print(userDictionary)
                            if let user = ADZUser(dictionary: userDictionary) {
                                callback(user, nil)
                            } else {
                                print("WARNING: could not recognize json format: \(userDictionary)")
                                callback(nil, nil)
                            }
                        } else {
                            print("WARNING: response did not contain valid json.")
                            callback(nil, error)
                        }
                    } catch let exc as NSException {
                        print("WARNING: error parsing JSON: \(exc.name) -> \(exc.reason)")
                        callback(nil, nil)
                    } catch let e as NSError {
                        let body = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("response: \(body)")
                        callback(nil, e)
                    }
                } else {
                    print("Received HTTP \(http.statusCode) from \(request.URL)")
                    let body = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("response: \(body)")
                    callback(nil, nil)
                }
            } else {
                callback(nil, error)
            }
        }
        task.resume()
    }
    
    
    /**
    Adds an interest for a user to UserDB.
    @param userKey the current user key. If nil, the saved userKey from the configured userKeyStore is used.
    @param callback a simple success/error callback to use when the response comes back
    */
    public func addUserInterest(interest: String, userKey: String?, callback: ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            print("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            print("WARNING: No userKey specified, and none can be found in the configured key store.")
            callback(false, nil)
            return
        }
        
        addUserInterest(interest, networkId: networkId, userKey: actualUserKey, callback: callback)
    }

    /**
    Adds an interest for a user to UserDB.
    @param interest an interest keyword to add for this user
    @param networkId the network ID for this action
    @param userKey the user to add the interest for
    @param callback a simple success/error callback to use when the response comes back
    */

    public func addUserInterest(interest: String, networkId: Int, userKey: String, callback: ADZResponseCallback) {
        let params = [
            "userKey": userKey,
            "interest": interest
        ]
        pixelRequest(networkId, action: "optout", params: params, callback: callback)
    }

    /**
    Opt a user out of tracking. Uses the `defaultNetworkId` set on `AdzerkSDK`.
    @param userKey the user to opt out. If nil, the saved userKey from the configured userKeyStore is used.
    @param callback a simple success/error callback to use when the response comes back
    */
    public func optOut(userKey: String?, callback: ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            print("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            print("WARNING: No userKey specified, and none can be found in the configured key store.")
            callback(false, nil)
            return
        }

        optOut(networkId, userKey: actualUserKey, callback: callback)
    }

    /**
    Opt a user out of tracking.
    @param networkId the network ID for this action
    @param userKey the user to opt out
    @param callback a simple success/error callback to use when the response comes back
    */
    public func optOut(networkId: Int, userKey: String, callback: ADZResponseCallback) {
        let params = [
            "userKey": userKey
        ]
        pixelRequest(networkId, action: "optout", params: params, callback: callback)
    }
    
    /** Retargets a user to a new segment.
    @param userKey the user to opt out
    @param brandId the brand this retargeting is for
    @param segmentId the segment the user is targeted to
    @param callback a simple success/error callback to use when the response comes back
    */
    public func retargetUser(userKey: String?, brandId: Int, segmentId: Int, callback: ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            print("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            print("WARNING: No userKey specified, and none can be found in the configured key store.")
            callback(false, nil)
            return
        }

        retargetUser(networkId, userKey: actualUserKey, brandId: brandId, segmentId: segmentId, callback: callback)
    }

    /** Retargets a user to a new segment.
    @param networkId the network ID for this request
    @param userKey the user to opt out
    @param brandId the brand this retargeting is for
    @param segmentId the segment the user is targeted to
    @param callback a simple success/error callback to use when the response comes back
    */
    public func retargetUser(networkId: Int, userKey: String, brandId: Int, segmentId: Int, callback: ADZResponseCallback) {
        let params = [
            "userKey": userKey
        ]
        let action = "rt/\(brandId)/\(segmentId)"
        pixelRequest(networkId, action: action, params: params, callback: callback)
    }

    // MARK - private
    
    /** 
        Makes a simple pixel request to perform an action. The response image is ignored.
        @param networkId the network ID for this action
        @param action the action to take, which becomes part of the path
        @param params the params for the action. Most of these require `userKey` at a minimum
        @param callback a simple success/error callback to use when the response comes back
    */
    func pixelRequest(networkId: Int, action: String, params: [String: String]?, callback: ADZResponseCallback) {
        let query = queryStringWithParams(params)
        guard let url = NSURL(string: "\(AdzerkUDBBaseUrl)/\(networkId)/\(action)/i.gif\(query)") else {
            print("WARNING: Could not construct proper URL for params: \(params)")
            callback(false, nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.allHTTPHeaderFields = [ "Content-Type": "" ] // image request, not json
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                callback(false, error)
            } else {
                let http = response as! NSHTTPURLResponse
                if http.statusCode == 200 {
                    callback(true, nil)
                } else {
                    print("Received HTTP \(http.statusCode) from \(request.URL!)")
                    if let data = data, body = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        print("Response: \(body)")
                    }
                    callback(false, nil)
                }
            }
        }
        task.resume()
    }

    /** 
        Builds a query string for appending on to a URL. Includes a preceding ? if the passed params are non-nil. Returns an empty string
        if the params are passed with nil. Both the key and the value of the params dictionary are URL encoded.
        @param params a string to string dictionary of parameters to convert to a URL query string
        @returns String
    */
    func queryStringWithParams(params: [String: String]?) -> String {
        guard let params = params else {
            return ""
        }
        
        return "?" + params.map { (k, v) -> String in
            let queryChars = NSCharacterSet.URLQueryAllowedCharacterSet()
            let encodedKey = k.stringByAddingPercentEncodingWithAllowedCharacters(queryChars)!
            let encodedVal = v.stringByAddingPercentEncodingWithAllowedCharacters(queryChars)!
            return "\(encodedKey)=\(encodedVal)"
        }.joinWithSeparator("&")
    }
    
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
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: requestTimeout)
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
        
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
            request.HTTPBody = data
            print("Posting JSON: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
            return request
        } catch let error as NSError {
            print("Error building placement request: \(error)")
            return nil
        }
    }
    
    private func buildPlacementResponse(data: NSData) -> ADZPlacementResponse? {
        do {
            let responseDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
            saveUserKey(responseDictionary)
            return ADZPlacementResponse(dictionary: responseDictionary)
        } catch {
            print("couldn't parse response as JSON")
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

