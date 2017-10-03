//
//  AdzerkSDK.swift
//  AdzerkSDK
//
//  Created by Ben Scheirman on 8/10/15.
//  Copyright (c) 2015 Adzerk. All rights reserved.
//

import Foundation
import UIKit

// Update this when making changes. Will ben sent in the UserAgent to identify the version of the SDK used in host applications.
let AdzerkSDKVersion = "1.0.3"

/** The base URL to use for API requests. */
let AdzerkBaseUrl = "https://engine.adzerk.net/api/v2"
let AdzerkUDBBaseUrl = "https://engine.adzerk.net/udb"

public typealias ADZResponseSuccessCallback = (ADZPlacementResponse) -> ()
public typealias ADZResponseFailureCallback = (Int?, String?, Error?) -> ()
public typealias ADZResponseCallback = (Bool, Error?) -> ()
public typealias ADZUserDBUserResponseCallback = (ADZUser?, Error?) -> ()


/** The primary class used to make requests against the API. */
@objc open class AdzerkSDK : NSObject {
    
    private var queue: DispatchQueue
    private var logger = ADZLogger()
    
    private static var _defaultNetworkId: Int?
    /** Provides storage for the default network ID to be used with all placement requests. If a value is present here,
        each placement request does not need to provide it.  Any value in the placement request will override this value.
        Useful for the common case where the network ID is contstant for your application. */
    open class var defaultNetworkId: Int? {
        get { return _defaultNetworkId }
        set { _defaultNetworkId = newValue }
    }
    
    private static var _defaultSiteId: Int?
    /** Provides storage for the default site ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is contstant for your application. */
    open class var defaultSiteId: Int? {
        get { return _defaultSiteId }
        set { _defaultSiteId = newValue }
    }
    
    /** Setter for defaultNetworkId. Provided for Objective-C compatibility. */
    open class func setDefaultNetworkId(_ networkId: Int) {
        defaultNetworkId = networkId
    }
    
    /** Setter for defaultSiteId. Provided for Objective-C compatibility. */
    open class func setDefaultSiteId(_ siteId: Int) {
        defaultSiteId = siteId
    }
    
    /** The class used to save & retrieve the user DB key. */
    let keyStore: ADZUserKeyStore
    
    /** Initializes a new instance of `AdzerkSDK` with a keychain-based userKeyStore.
    */
    public convenience override init() {
        self.init(userKeyStore: ADZKeychainUserKeyStore(), queue: nil)
    }
    
    /** Initializes a new instance of `AdzerkSDK`.
        @param userKeyStore provide a value for this if you want to customize the way user keys are stored & retrieved. The default is `ADZKeychainUserKeyStore`.
    */
    public init(userKeyStore: ADZUserKeyStore, queue: DispatchQueue? = nil) {
        self.keyStore = userKeyStore
        self.queue = queue ?? DispatchQueue.main
    }
    
    /** Requests placements with explicit success and failure callbacks. Provided for Objective-C compatibility.
        See `requestPlacements:options:completion` for complete documentation.
    */
    public func requestPlacements(_ placements: [ADZPlacement], options: ADZPlacementRequestOptions? = nil,
        success: @escaping (ADZPlacementResponse) -> (),
        failure: @escaping (Int, String?, NSError?) -> ()) {
        
        requestPlacements(placements, options: options) { response in
            switch response {
            case .success(let placementResponse):
                success(placementResponse)
            case .badRequest(let statusCode, let body):
                failure(statusCode, body, nil)
            case .badResponse(let body):
                failure(0, body, nil)
            case .error(let error):
                failure(0, nil, error as NSError)
            }
        }
    }
    
    /** Requests a single placement using only required parameters. This method is a convenience over the other placement request methods.
        @param div the div name to request
        @param adTypes an array of integers representing the ad types to request. The full list can be found at https://github.com/adzerk/adzerk-api/wiki/Ad-Types .
        @completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    open func requestPlacementInDiv(_ div: String, adTypes: [Int], completion: @escaping (ADZResponse) -> ()) {
        if let placement = ADZPlacement(divName: div, adTypes: adTypes) {
            requestPlacement(placement, completion: completion)
        }
    }

    /** Requests a single placement.
        @param placement the placement details to request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    open func requestPlacement(_ placement: ADZPlacement, completion: @escaping (ADZResponse) -> ()) {
       requestPlacements([placement], completion: completion)
    }

    /** Requests multiple placements.
        @param placements an array of placement details to request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    open func requestPlacements(_ placements: [ADZPlacement], completion: @escaping (ADZResponse) -> ()) {
        requestPlacements(placements, options: nil, completion: completion)
    }
 
    /** Requests multiple placements with additional options. The options can provide well-known or arbitrary parameters to th eoverall request.
        @param placements an array of placement details to request
        @param options an optional instance of `ADZPlacementRequestOptions` that provide top-level attributes to the request
        @param completion a callback block that you provide to handle the response. The block will be given an `ADZResponse` object.
    */
    open func requestPlacements(_ placements: [ADZPlacement], options: ADZPlacementRequestOptions?, completion: @escaping (ADZResponse) -> ()) {
        if let request = buildPlacementRequest(placements, options: options) {
            let task = session.dataTask(with: request) {
                data, response, error in
                
                if let error = error {
                    self.queue.async {
                        completion(.error(error))
                    }
                } else {
                    let http = response as! HTTPURLResponse
                    guard let data = data else {
                        self.queue.async {
                            completion(.badResponse("<no response>"))
                        }
                        return
                    }
                    
                    if http.statusCode == 200 {
                        if let resp = self.buildPlacementResponse(data) {
                            self.logger.debug("Response: \(String(data: data, encoding: .utf8) ?? "<no response>"))")
                            self.queue.async {
                                completion(ADZResponse.success(resp))
                            }
                        } else {
                            let bodyString = (String(data: data, encoding: .utf8)) ?? "<no body>"
                            self.queue.async {
                                completion(ADZResponse.badResponse(bodyString))
                            }
                        }
                    } else {
                        let bodyString = (String(data: data, encoding: .utf8)) ?? "<no body>"
                        self.queue.async {
                            completion(.badRequest(http.statusCode, bodyString))
                        }
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
    open func postUserProperties(_ userKey: String?, properties: [String : Any], callback: @escaping ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            logger.warn("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
    
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            logger.warn("WARNING: No userKey specified, and none can be found in the configured key store.")
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
    open func postUserProperties(_ networkId: Int, userKey: String, properties: [String : Any], callback: @escaping ADZResponseCallback) {
        guard let url = URL(string: "\(AdzerkUDBBaseUrl)/\(networkId)/custom?userKey=\(userKey)") else {
            logger.warn("WARNING: Could not build URL with provided params. Network ID: \(networkId), userKey: \(userKey)")
            callback(false, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        request.httpMethod = "POST"
        
        do {
            let data = try JSONSerialization.data(withJSONObject: properties, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = data
            let task = session.dataTask(with: request) {
                (data, response, error) in
                if error == nil {
                    let http = response as! HTTPURLResponse
                    if http.statusCode == 200 {
                        callback(true, nil)
                    } else {
                        self.logger.debug("Received HTTP \(http.statusCode) from \(String(describing: request.url))")
                        callback(false, nil)
                    }
                } else {
                    callback(false, error)
                }
            }
            task.resume()
        }
        catch let exc as NSException {
            logger.warn("WARNING: Could not serialize the submitted properties into JSON: \(properties).")
            logger.warn("\(exc.name) -> \(exc.reason ?? "<no reason>")")
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
    open func readUser(_ userKey: String?, callback: @escaping ADZUserDBUserResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            logger.warn("WARNING: No defaultNetworkId set.")
            callback(nil, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            logger.warn("WARNING: No userKey specified, and none can be found in the configured key store.")
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
    open func readUser(_ networkId: Int, userKey: String, callback: @escaping ADZUserDBUserResponseCallback) {
        guard let url = URL(string: "\(AdzerkUDBBaseUrl)/\(networkId)/read?userKey=\(userKey)") else {
            logger.warn("WARNING: Could not build URL with provided params. Network ID: \(networkId), userKey: \(userKey)")
            callback(nil, nil)
            return
        }
        
        var request = URLRequest(url: url)

        // Fails with HTTP 500 if the default application/json is specified.
        request.allHTTPHeaderFields = [
            "Content-Type" : ""
        ]
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            if error == nil {
                let http = response as! HTTPURLResponse
                if http.statusCode == 200 {
                    do {
                        if let userDictionary = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as? [String: AnyObject] {
                            print(userDictionary)
                            if let user = ADZUser(dictionary: userDictionary) {
                                callback(user, nil)
                            } else {
                                self.logger.warn("WARNING: could not recognize json format: \(userDictionary)")
                                callback(nil, nil)
                            }
                        } else {
                            self.logger.warn("WARNING: response did not contain valid json.")
                            callback(nil, error)
                        }
                    } catch let exc as NSException {
                        self.logger.error("WARNING: error parsing JSON: \(exc.name) -> \(String(describing: exc.reason))")
                        callback(nil, nil)
                    } catch let e as NSError {
                        let body = String(data: data!, encoding: String.Encoding.utf8)
                        self.logger.error("response: \(String(describing: body))")
                        callback(nil, e)
                    }
                } else {
                    self.logger.debug("Received HTTP \(http.statusCode) from \(String(describing: request.url))")
                    let body = String(data: data!, encoding: String.Encoding.utf8)
                    self.logger.debug("response: \(String(describing: body))")
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
    open func addUserInterest(_ interest: String, userKey: String?, callback: @escaping ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            logger.warn("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            logger.warn("WARNING: No userKey specified, and none can be found in the configured key store.")
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

    open func addUserInterest(_ interest: String, networkId: Int, userKey: String, callback: @escaping ADZResponseCallback) {
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
    open func optOut(_ userKey: String?, callback: @escaping ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            logger.warn("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            logger.warn("WARNING: No userKey specified, and none can be found in the configured key store.")
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
    open func optOut(_ networkId: Int, userKey: String, callback: @escaping ADZResponseCallback) {
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
    open func retargetUser(_ userKey: String?, brandId: Int, segmentId: Int, callback: @escaping ADZResponseCallback) {
        guard let networkId = AdzerkSDK.defaultNetworkId else {
            logger.warn("WARNING: No defaultNetworkId set.")
            callback(false, nil)
            return
        }
        
        guard let actualUserKey = userKey ?? keyStore.currentUserKey() else {
            logger.warn("WARNING: No userKey specified, and none can be found in the configured key store.")
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
    open func retargetUser(_ networkId: Int, userKey: String, brandId: Int, segmentId: Int, callback: @escaping ADZResponseCallback) {
        let params = [
            "userKey": userKey
        ]
        let action = "rt/\(brandId)/\(segmentId)"
        pixelRequest(networkId, action: action, params: params, callback: callback)
    }
    
    /**
        Sends a request to record an impression. This is a fire-and-forget request, the response is ignored.
        @param url a valid URL retrieved from an ADZPlacementDecision
    */
    open func recordImpression(_ url: URL) {
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                self.logger.error("Error recording impression: \(error)")
            } else {
                // impression recorded
            }
        }
        task.resume()
    }

    // MARK - private
    
    /** 
        Makes a simple pixel request to perform an action. The response image is ignored.
        @param networkId the network ID for this action
        @param action the action to take, which becomes part of the path
        @param params the params for the action. Most of these require `userKey` at a minimum
        @param callback a simple success/error callback to use when the response comes back
    */
    func pixelRequest(_ networkId: Int, action: String, params: [String: String]?, callback: @escaping ADZResponseCallback) {
        let query = queryStringWithParams(params)
        guard let url = URL(string: "\(AdzerkUDBBaseUrl)/\(networkId)/\(action)/i.gif\(query)") else {
            logger.warn("WARNING: Could not construct proper URL for params: \(params ?? [:])")
            callback(false, nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [ "Content-Type": "" ] // image request, not json
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                callback(false, error)
            } else {
                let http = response as! HTTPURLResponse
                if http.statusCode == 200 {
                    callback(true, nil)
                } else {
                    self.logger.debug("Received HTTP \(http.statusCode) from \(request.url!)")
                    if let data = data, let body = String(data: data, encoding: String.Encoding.utf8) {
                        self.logger.debug("Response: \(body)")
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
    func queryStringWithParams(_ params: [String: String]?) -> String {
        guard let params = params else {
            return ""
        }
        
        return "?" + params.map { (entry: (String, String)) in
            let (k, v) = entry
            let queryChars = NSCharacterSet.urlQueryAllowed
            let encodedKey = k.addingPercentEncoding(withAllowedCharacters: queryChars)!
            let encodedVal = v.addingPercentEncoding(withAllowedCharacters: queryChars)!
            return "\(encodedKey)=\(encodedVal)"
        }.joined(separator: "&")
    }
    
    lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.ephemeral
        config.httpAdditionalHeaders = [
            "User-Agent" : UserAgentProvider.instance.userAgent,
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        return config
    }()
    
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    }()
    
    private var baseURL: URL {
        return URL(string: AdzerkBaseUrl)!
    }
    
    private let requestTimeout: TimeInterval = 15
    
    private func buildPlacementRequest(_ placements: [ADZPlacement], options: ADZPlacementRequestOptions?) -> URLRequest? {
        let url = baseURL
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: requestTimeout)
        request.httpMethod = "POST"
        
        var body: [String: Any] = [
            "placements": placements.map { $0.serialize() },
            "time": Int(Date().timeIntervalSince1970)
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
            let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            request.httpBody = data
            logger.debug("Posting JSON: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
            return request
        } catch let error as NSError {
            logger.error("Error building placement request: \(error)")
            return nil
        }
    }
    
    private func buildPlacementResponse(_ data: Data) -> ADZPlacementResponse? {
        do {
            let responseDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
            saveUserKey(responseDictionary)
            return ADZPlacementResponse(dictionary: responseDictionary)
        } catch {
            logger.error("couldn't parse response as JSON")
            return nil
        }
    }
    
    private func saveUserKey(_ response: [String: AnyObject]) {
        if let userSection = response["user"] as? [String: AnyObject] {
            if let userKey = userSection["key"] as? String {
                keyStore.saveUserKey(userKey)
            }
        }
    }
}

// This provider object constructs the user agent only once, and is used repeatedly.
fileprivate struct UserAgentProvider {
    static var instance = UserAgentProvider()
    
    private init() {
    }
    
    lazy var userAgent: String  = {
        var string = "AdzerkSDK/\(AdzerkSDKVersion)"
        let mainBundle = Bundle.main
        
        if let bundleName = mainBundle.object(forInfoDictionaryKey: "CFBundleName"),
            let bundleVersion = mainBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            
            let deviceName = self.deviceModelName
            let osVersion = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
            string.append("  (\(bundleName)/\(bundleVersion) - \(deviceName)/\(osVersion)   )")
        }
        
        return string
    }()
    
    var deviceModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad6,11", "iPad6,12":                    return "iPad 5"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
        case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
        case "AppleTV5,3":                              return "Apple TV"
        case "AppleTV6,2":                              return "Apple TV 4K"
        case "AudioAccessory1,1":                       return "HomePod"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
}
