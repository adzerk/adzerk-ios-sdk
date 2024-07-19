import Foundation

final class NoRedirectSessionDelegate : NSObject, URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler complete: @escaping (URLRequest?) -> Void) {
        complete(nil)
    }
}
