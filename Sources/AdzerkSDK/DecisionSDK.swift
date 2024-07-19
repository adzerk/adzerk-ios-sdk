import Foundation

/// Represents the interface for making requests against the Adzerk Decision API
public class DecisionSDK {
    
    /** Provides storage for the default network ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is constant for your application. */
    public var defaultNetworkId: Int?
    
    /** Provides storage for the default site ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is constant for your application.
    */
    public var defaultSiteId: Int?
    
    /** The base URL template to use for API requests. {subdomain} must be replaced in this template string before use. */
    private let adzerkHostnameTemplate = "{subdomain}.adzerk.net"
    
    private var hostOverride: String?
    
    /** The host to use for outgoing API requests. If not set, a default Adzerk hostname will be
     used that is based on the default network ID. This must be set prior to making requests.
     
     Failing to set defaultNetworkID or host explicitly will result in a `fatalError`.
     
     Note that the defaultNetworkID-based subdomain will not change if a different networkID is
     supplied for a specific request.
     */
    public var host: String {
        get {
            if let hostOverride = hostOverride {
                return hostOverride
            }
            
            guard let networkId = defaultNetworkId else {
                fatalError("You must set the defaultNetworkId or set a specific subdomain on `AdzerkSDK`")
            }
            let subdomain = "e-\(networkId)"
            return adzerkHostnameTemplate.replacingOccurrences(of: "{subdomain}", with: subdomain)
        }
        set { hostOverride = newValue }
    }
    
    private let keyStore: UserKeyStore
    private let logger: Logger
    private let transport: Transport
    private let session: URLSession
    private let queue: DispatchQueue
    private let requestTimeout: TimeInterval
    
    private static var sessionConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["X-Adzerk-Sdk-Version" : "adzerk-decision-sdk-ios:\(AdzerkDecisionSDKVersionString)"]
        return config
    }
    
    /** Initializes a new instance of `AdzerkSDK`
     Parameters:
     - keyStore: The object that will store user keys. Defaults to a Keychain-based store.
     - queue: The queue that all callbacks will be dispatched on. Defaults to `DispatchQueue.main`.
     */
    public init(
        defaultNetworkId: Int? = nil,
        defaultSiteId: Int? = nil,
        keyStore: UserKeyStore = UserKeyStoreKeychain(),
        logger: Logger = Logger(),
        transport: Transport? = nil,
        queue: DispatchQueue = .main,
        requestTimeout: TimeInterval = 30
    ) {
        self.defaultNetworkId = defaultNetworkId
        self.defaultSiteId = defaultSiteId
        self.keyStore = keyStore
        self.queue = queue
        let session = URLSession(configuration: Self.sessionConfiguration)
        self.session = session
        self.requestTimeout = requestTimeout
        self.transport = transport ?? NetworkTransport(session: session, logger: logger, callbackQueue: queue)
        self.logger = logger
    }
    
    public func request<P: Placement>(placement: P, options: PlacementRequest<P>.Options? = nil, completion: @escaping (Result<PlacementResponse, AdzerkError>) -> Void) {
        request(placements: [placement], options: options, completion: completion)
    }
    
    public func request<P: Placement>(placements: [P], options: PlacementRequest<P>.Options? = nil, completion: @escaping (Result<PlacementResponse, AdzerkError>) -> Void) {
        do {
            let url = Endpoint.decisionAPI.baseURL(withHost: host)
            var req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: requestTimeout)
            req.httpMethod = "POST"
            req.httpBody = try PlacementRequest(placements: placements, options: options, userKeyStore: keyStore, logger: logger).encodeBody()
            
            transport.send(req,
                           decode: { data in
                                let decoder = AdzerkJSONDecoder()
                                let response = try decoder.decode(PlacementResponse.self, from: data)
                                
                                // intercept response and set the user key
                                if let key = response.user?.key {
                                    self.keyStore.save(userKey: key)
                                }
                            
                                return response
                           },
                           completion: completion)
        } catch {
            queue.async {
                completion(.failure(.errorPreparingRequest(nil)))
            }
        }
    }
    
    /// Records an impression from a decision impression URL. This is a fire and forget request
    public func recordImpression(pixelURL: URL) {
        let request = URLRequest(url: pixelURL)
        transport.send(request) { [unowned self] result in
            if case .failure(let error) = result {
                self.logger.log(.error, message: "Error recording impression for \(pixelURL): \(error)")
            }
        }
    }
    
    public func firePixel(
        url: URL,
        override: Double? = nil,
        additional: Double? = nil,
        grossMerchandiseValue: Double? = nil,
        completion complete: @escaping @Sendable (Result<FirePixelResponse, AdzerkError>) -> Void
    ) {
        let callbackQueue: DispatchQueue = .main

        var url = url
        if let override = override {
            url = url.appendingQueryParameters(["override": String(override)])
        }
        if let additional = additional {
            url = url.appendingQueryParameters(["additional": String(additional)])
        }
        if let grossMerchandiseValue = grossMerchandiseValue {
            url = url.appendingQueryParameters(["gmv": String(grossMerchandiseValue)])
        }
        let urlRequest = URLRequest(url: url)
        let sessionDelegate = NoRedirectSessionDelegate()
        let session = URLSession(configuration: Self.sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                callbackQueue.async {
                    complete(.failure(.networkingError(error)))
                }
                return
            }

            guard let http = response as? HTTPURLResponse else {
                callbackQueue.async {
                    complete(.failure(.invalidResponse))
                }
                return
            }

            let statusCode = http.statusCode
            let location = http.allHeaderFields["Location"] as? String
            let firePixelResponse = FirePixelResponse(statusCode: statusCode, location: location)

            callbackQueue.async {
                complete(.success(firePixelResponse))
            }
        }

        task.resume()
    }
    
    public func placements(networkId: Int? = nil, siteId: Int? = nil) -> Placements {
        guard let networkId = networkId ?? defaultNetworkId else {
            fatalError("You must provide a networkId or set the defaultNetworkId on `DecisionSDK`")
        }
        guard let siteId = siteId ?? defaultSiteId else {
            fatalError("You must provide a siteId or set the defaultSiteId on `DecisionSDK`")
        }
        return Placements(networkId: networkId, siteId: siteId)
    }
    
    public func userDB(networkId: Int? = nil) -> UserDB {
        guard let networkId = networkId ?? defaultNetworkId else {
            fatalError("You must provide a networkId or set the defaultNetworkId on `DecisionSDK`")
        }
        return UserDB(
            host: host,
            networkId: networkId,
            keyStore: keyStore,
            logger: logger,
            transport: transport)
    }
}

#if swift(>=5.5)

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
//@MainActor
extension DecisionSDK {
    public func request<P: Placement>(placement: P, options: PlacementRequest<P>.Options? = nil) async -> Result<PlacementResponse, AdzerkError> {
        return await request(placements: [placement], options: options)
    }
    
    public func request<P: Placement>(placements: [P], options: PlacementRequest<P>.Options? = nil) async -> Result<PlacementResponse, AdzerkError> {
        do {
            let kstore = keyStore
            
            let url = Endpoint.decisionAPI.baseURL(withHost: host)
            var req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: requestTimeout)
            req.httpMethod = "POST"
            req.httpBody = try PlacementRequest(placements: placements, options: options, userKeyStore: kstore, logger: logger).encodeBody()
            
            
            return await transport.send(req, decode: { data in
                let decoder = AdzerkJSONDecoder()
                let response = try decoder.decode(PlacementResponse.self, from: data)
                
                // intercept response and set the user key
                if let key = response.user?.key {
                    kstore.save(userKey: key)
                }
            
                return response
            })
        } catch {
            return .failure(.errorPreparingRequest(nil))
        }
    }
    
    public func firePixel(url: URL) async -> Result<FirePixelResponse, AdzerkError> {
        return await firePixel(url: url, override: nil, additional: nil)
    }

    public func firePixel(url: URL, override: Double) async -> Result<FirePixelResponse, AdzerkError> {
        return await firePixel(url: url, override: override, additional: nil)
    }

    public func firePixel(url: URL, additional: Double) async -> Result<FirePixelResponse, AdzerkError> {
        return await firePixel(url: url, override: nil, additional: additional)
    }

    private func firePixel(url: URL, override: Double?, additional: Double?) async -> Result<FirePixelResponse, AdzerkError> {
        var url = url
        if let override = override {
            url = url.appendingQueryParameters(["override": String(override)])
        }
        if let additional = additional {
            url = url.appendingQueryParameters(["additional": String(additional)])
        }
        let urlRequest = URLRequest(url: url)
        let sessionDelegate = NoRedirectSessionDelegate()
        let session = URLSession(configuration: Self.sessionConfiguration, delegate: sessionDelegate, delegateQueue: nil)
        do {
            let (_, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            let statusCode = http.statusCode
            let location = http.allHeaderFields["Location"] as? String
            let firePixelResponse = FirePixelResponse(statusCode: statusCode, location: location)
            return .success(firePixelResponse)
        } catch let err {
            return .failure(.networkingError(err))
        }
    }
}

#endif
