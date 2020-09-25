import Foundation

public struct AdzerkSDK {
    /** Provides storage for the default network ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is constant for your application. */
    public static var defaultNetworkId: Int? = 0
    
    /** Provides storage for the default site ID to be used with all placement requests. If a value is present here,
    each placement request does not need to provide it.  Any value in the placement request will override this value.
    Useful for the common case where the network ID is constant for your application.
    */
    public static var defaultSiteId: Int? = 0
    
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
    private let queue: DispatchQueue
    
    /** Initializes a new instance of `AdzerkSDK`
     Parameters:
     - keyStore: The object that will store user keys. Defaults to a Keychain-based store.
     - queue: The queue that all callbacks will be dispatched on. Defaults to `DispatchQueue.main`.
     */
    public init(keyStore: UserKeyStore = UserKeyStoreKeychain(), queue: DispatchQueue = .main) {
        self.keyStore = keyStore
        self.queue = queue
    }
    
    public func request<P: Placement>(placements: [P]) {
        
    }
}
