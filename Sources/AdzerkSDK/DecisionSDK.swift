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
    private let session: URLSession
    private let queue: DispatchQueue
    private let requestTimeout: TimeInterval
    
    /** Initializes a new instance of `AdzerkSDK`
     Parameters:
     - keyStore: The object that will store user keys. Defaults to a Keychain-based store.
     - queue: The queue that all callbacks will be dispatched on. Defaults to `DispatchQueue.main`.
     */
    public init(keyStore: UserKeyStore = UserKeyStoreKeychain(), queue: DispatchQueue = .main, requestTimeout: TimeInterval = 30) {
        self.keyStore = keyStore
        self.queue = queue
        self.session = URLSession(configuration: .default)
        self.requestTimeout = requestTimeout
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
            send(req, completion: completion)
        } catch {
            dispatch(.failure(.errorPreparingRequest), to: completion)
        }
    }
    
//    public func userDB(networkId: Int? = nil) -> UserDB {
//        guard let networkId = networkId ?? AdzerkSDK.defaultNetworkId else {
//            fatalError("You must provide a networkId or set the defaultNetworkId on `AdzerkSDK`")
//        }
//        return UserDB(networkId: networkId, keyStore: keyStore)
//    }
    
    private func send<ResponseType: Decodable>(_ request: URLRequest, completion: @escaping (Result<ResponseType, AdzerkError>) -> Void) {
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                self.dispatch(.failure(.networkingError(error)), to: completion)
                return
            }
            
            let data = data ?? Data()
            if let http = response as? HTTPURLResponse {
                Self.logger.log(.debug, message: "Received HTTP \(http.statusCode) from \(request.url?.absoluteString ?? "")")
                if http.statusCode == 200 {
                    print("Response: \(String(data: data, encoding: .utf8) ?? "")")
                        do {
                            let decoder = AdzerkJSONDecoder()
                            let response = try decoder.decode(ResponseType.self, from: data)
                            self.dispatch(.success(response), to: completion)
                        } catch let e as DecodingError {
                            self.dispatch(.failure(.decodingError(e)), to: completion)
                        }
                        catch { /* not possible */ }
                } else {
                    self.dispatch(.failure(.httpError(http.statusCode, data)), to: completion)
                }
            } else {
                self.dispatch(.failure(.invalidResponse), to: completion)
            }
        }
        
        Self.logger.log(.debug, message: "HTTP \(request.httpMethod ?? "?") to \(request.url?.absoluteString ?? "?")")
        task.resume()
    }
    
    private func dispatch<R, E>(_ result: Result<R, E>, to completion: @escaping (Result<R, E>) -> Void) {
        queue.async {
            completion(result)
        }
    }
}
