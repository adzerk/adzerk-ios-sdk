import Foundation

/// Represents the interface for making requests against the Adzerk Decision API
public class DecisionSDK {
    /** Provides storage for the default network ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is constant for your application. */
    public static var defaultNetworkId: Int?
    
    /** Provides storage for the default site ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is constant for your application.
    */
    public static var defaultSiteId: Int?
    
    static var logger = Logger()
    
    /** The base URL template to use for API requests. {subdomain} must be replaced in this template string before use. */
    private static let AdzerkHostnameTemplate = "{subdomain}.adzerk.net"
    
    private static var _hostOverride: String?
    
    /** The host to use for outgoing API requests. If not set, a default Adzerk hostname will be
     used that is based on the default network ID. This must be set prior to making requests.
     
     Failing to set defaultNetworkID or host explicitly will result in a `fatalError`.
     
     Note that the defaultNetworkID-based subdomain will not change if a different networkID is
     supplied for a specific request.
     */
    public static var host: String {
        get {
            if let hostOverride = _hostOverride {
                return hostOverride
            }
            
            guard let networkId = defaultNetworkId else {
                fatalError("You must set the defaultNetworkId or set a specific subdomain on `AdzerkSDK`")
            }
            let subdomain = "e-\(networkId)"
            return AdzerkHostnameTemplate.replacingOccurrences(of: "{subdomain}", with: subdomain)
        }
        set { _hostOverride = newValue }
    }
    
    private let keyStore: UserKeyStore
    private let transport: Transport
    private let session: URLSession
    private let queue: DispatchQueue
    private let requestTimeout: TimeInterval
    
    /** Initializes a new instance of `AdzerkSDK`
     Parameters:
     - keyStore: The object that will store user keys. Defaults to a Keychain-based store.
     - queue: The queue that all callbacks will be dispatched on. Defaults to `DispatchQueue.main`.
     */
    public init(keyStore: UserKeyStore = UserKeyStoreKeychain(),
                transport: Transport? = nil,
                queue: DispatchQueue = .main, requestTimeout: TimeInterval = 30) {
        self.keyStore = keyStore
        self.queue = queue
        let session = URLSession(configuration: .default)
        self.session = session
        self.requestTimeout = requestTimeout
        self.transport = transport ?? NetworkTransport(session: session, logger: Self.logger, callbackQueue: queue)
    }
    
    public func request<P: Placement>(placement: P, options: PlacementRequest<P>.Options? = nil, completion: @escaping (Result<PlacementResponse, AdzerkError>) -> Void) {
        request(placements: [placement], options: nil, completion: completion)
    }
    
    public func request<P: Placement>(placements: [P], options: PlacementRequest<P>.Options? = nil, completion: @escaping (Result<PlacementResponse, AdzerkError>) -> Void) {
        do {
            let url = Endpoint.decisionAPI.baseURL()
            var req = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: requestTimeout)
            req.httpMethod = "POST"
            req.httpBody = try PlacementRequest(placements: placements, options: options, userKeyStore: keyStore).encodeBody()
            transport.send(req) { (result: Result<PlacementResponse, AdzerkError>) in
                // intercept response and set the user key
                if case let .success(response) = result {
                    if let key = response.user?.key {
                        self.keyStore.save(userKey: key)
                    }
                }
                completion(result)
            }
        } catch {
            queue.async {
                completion(.failure(.errorPreparingRequest))
            }
        }
    }
    
    public func userDB(networkId: Int? = nil) -> UserDB {
        guard let networkId = networkId ?? DecisionSDK.defaultNetworkId else {
            fatalError("You must provide a networkId or set the defaultNetworkId on `AdzerkSDK`")
        }
        return UserDB(
            host: DecisionSDK.host,
            networkId: networkId,
            keyStore: keyStore,
            logger: Self.logger,
            transport: transport)
    }
}
