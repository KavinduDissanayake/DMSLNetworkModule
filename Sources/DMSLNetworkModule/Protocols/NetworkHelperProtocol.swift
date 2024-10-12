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




extension Data {
    // Determine the file extension based on the data signature
    func fileExtension() -> String {
        var byte = [UInt8](repeating: 0, count: 1)
        self.copyBytes(to: &byte, count: 1)
        
        switch byte[0] {
        case 0xFF: return "jpg"
        case 0x89: return "png"
        case 0x47: return "gif"
        case 0x25: return "pdf"
        case 0xD0: return "doc"
        case 0x46: return "txt"
        case 0x00: return "mp4"
        default: return "bin"
        }
    }
    
    // Determine MIME type based on file extension
    func mimeType() -> String {
        let fileExtension = self.fileExtension()
        
        switch fileExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "pdf": return "application/pdf"
        case "mp4": return "video/mp4"
        case "doc": return "application/msword"
        case "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }
}

extension Data {
      func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}



