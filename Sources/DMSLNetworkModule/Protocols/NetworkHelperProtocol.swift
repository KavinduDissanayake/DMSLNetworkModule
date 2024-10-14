import Foundation
import Alamofire


// MARK: - NetworkHelperProtocol
public protocol NetworkHelperProtocol {
    func makeAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod,
        headers: [String: String],
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
    func makeUploadAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod,
        headers: [String: String],
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
    func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod,
        headers: [String: String]
    ) async throws -> T
    
    func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod,
        headers: [String: String]
    ) async throws -> T
}


//// MARK: - Retry and Throttle Interceptor
public class RetryAndThrottleInterceptor: RequestInterceptor {
    private let retryLimit: Int
    private let exponentialBackoffBase: Double
    private let exponentialBackoffScale: TimeInterval
    private let throttleInterval: TimeInterval
    
    public init(retryLimit: Int, exponentialBackoffBase: Double, exponentialBackoffScale: TimeInterval, throttleInterval: TimeInterval) {
        self.retryLimit = retryLimit
        self.exponentialBackoffBase = exponentialBackoffBase
        self.exponentialBackoffScale = exponentialBackoffScale
        self.throttleInterval = throttleInterval
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let retryCount = request.retryCount
        guard retryCount < retryLimit else {
            return completion(.doNotRetry)
        }
        
        let backoffDelay = pow(exponentialBackoffBase, Double(retryCount)) * exponentialBackoffScale
        completion(.retryWithDelay(backoffDelay))
    }
}






