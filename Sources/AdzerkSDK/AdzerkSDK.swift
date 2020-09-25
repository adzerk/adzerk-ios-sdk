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
}
