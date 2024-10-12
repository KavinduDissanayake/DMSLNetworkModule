import Foundation
import Alamofire

// MARK: - NetworkConfiguration
public struct NetworkConfiguration {
    public var retryLimit: Int
    public var exponentialBackoffBase: Double
    public var exponentialBackoffScale: TimeInterval
    public var throttleInterval: TimeInterval
    public var enableLogging: Bool
    public var enableSSLPinning: Bool
    public var tokenStorageKey: String
    public var pinnedDomains: [String: ServerTrustEvaluating] // Configurable SSL pinning domains

    public init(retryLimit: Int = 2,
                exponentialBackoffBase: Double = 2.0,
                exponentialBackoffScale: TimeInterval = 1.5,
                throttleInterval: TimeInterval = 0.003,
                enableLogging: Bool = true,
                enableSSLPinning: Bool = true,
                tokenStorageKey: String = "server_token",
                pinnedDomains: [String: ServerTrustEvaluating] = [:]) { // Default: empty, user-configurable
        self.retryLimit = retryLimit
        self.exponentialBackoffBase = exponentialBackoffBase
        self.exponentialBackoffScale = exponentialBackoffScale
        self.throttleInterval = throttleInterval
        self.enableLogging = enableLogging
        self.enableSSLPinning = enableSSLPinning
        self.tokenStorageKey = tokenStorageKey
        self.pinnedDomains = pinnedDomains // User can pass their own pinned domains
    }
}

// MARK: - NetworkHelperProtocol
public protocol NetworkHelperProtocol {
    func makeAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHelperHttpMethod,
        headers: HTTPHeaders,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
    func makeUploadAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHelperHttpMethod,
        headers: HTTPHeaders,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
    
    func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHelperHttpMethod,
        headers: HTTPHeaders
    ) async throws -> T
    
    func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHelperHttpMethod,
        headers: HTTPHeaders
    ) async throws -> T
}

// MARK: - NetworkError Enum
public enum NetworkError: Error, Equatable {
    case FORBIDDEN
    case BAD_TOKEN
    case NO_INTERNET_CONNECTION
    case TIMEOUT
    case NETWORK_RESOURCE_NOT_FOUND
    case SERVER_DOWN_FOR_MAINTENANCE
    case SERVER_OUTAGE
    case DATA_PARSE_ERROR
    case BACKEND_ERROR
    case GENERAL_NETWORK_ERROR
    case CLIENT_SIDE_ERROR
    case SERVER_SIDE_ERROR
    case SSL_PINNING_FAILED
    case UNHANDLED_ERROR(reason: String)
    case API_ERROR(code: Int, message: String)
    case THROTTLED_ERROR(message: String)
    case UNAUTHENTICATED

    public var description: String {
        switch self {
        case .FORBIDDEN: return "Your session has expired. Please log in again."
        case .BAD_TOKEN: return "Invalid session token. Please log in again."
        case .NO_INTERNET_CONNECTION: return "No Internet Connection! Please check your network settings."
        case .TIMEOUT: return "The request timed out. Please try again."
        case .NETWORK_RESOURCE_NOT_FOUND: return "The requested resource could not be found."
        case .SERVER_DOWN_FOR_MAINTENANCE: return "The server is currently down for maintenance."
        case .SERVER_OUTAGE: return "The server is experiencing an outage."
        case .DATA_PARSE_ERROR: return "Failed to parse the response data."
        case .BACKEND_ERROR: return "An error occurred on the server side."
        case .GENERAL_NETWORK_ERROR: return "A network error occurred. Please check your internet connection."
        case .CLIENT_SIDE_ERROR: return "An error occurred on the client side."
        case .SERVER_SIDE_ERROR: return "An error occurred on the server side."
        case .SSL_PINNING_FAILED: return "SSL Pinning failed. Please contact support."
        case .UNHANDLED_ERROR(let reason): return "Unhandled error: \(reason)"
        case .API_ERROR(let code, let message): return "API error (Code: \(code)): \(message)"
        case .THROTTLED_ERROR(let message): return "Error: \(message)"
        case .UNAUTHENTICATED: return "Your session has expired. Please log in."
        }
    }
}


//// MARK: - NetworkHelper
//public final class NetworkHelper: NetworkHelperProtocol {
//    public var customSession: Session
//    private let config: NetworkConfiguration
//    private let interceptor: RequestInterceptor
//
//    // MARK: - Singleton
//    public static let shared = NetworkHelper()
//
//    // MARK: - Initializer with Config
//    public init(configuration: NetworkConfiguration = NetworkConfiguration()) {
//        self.config = configuration
//        self.interceptor = RetryAndThrottleInterceptor(
//            retryLimit: configuration.retryLimit,
//            exponentialBackoffBase: configuration.exponentialBackoffBase,
//            exponentialBackoffScale: configuration.exponentialBackoffScale,
//            throttleInterval: configuration.throttleInterval
//        )
//        self.customSession = NetworkHelper.configureCustomSession(
//            retryPolicy: interceptor,
//            enableSSLPinning: configuration.enableSSLPinning,
//            pinnedDomains: configuration.pinnedDomains
//        )
//    }
//
//    // MARK: - Configurable Custom Session
//    public static func configureCustomSession(retryPolicy: RequestInterceptor, enableSSLPinning: Bool, pinnedDomains: [String: ServerTrustEvaluating]) -> Session {
//        var serverTrustManager: ServerTrustManager?
//        
//        if enableSSLPinning && !pinnedDomains.isEmpty {
//            serverTrustManager = ServerTrustManager(evaluators: pinnedDomains)
//        }
//        
//        return Session(
//            interceptor: retryPolicy,
//            serverTrustManager: serverTrustManager
//        )
//    }
//
//    // MARK: - Logging
//    private func log(_ message: String) {
//        if config.enableLogging {
//            print("🔍 \(message)")
//        }
//    }
//
//    // MARK: - API Request (Async)
//    public func makeAPIRequestAsync<T: Decodable>(
//        url: String,
//        parameters: [String: Any]?,
//        method: NetworkHelperHttpMethod = .post,
//        headers: HTTPHeaders
//    ) async throws -> T {
//        return try await withCheckedThrowingContinuation { continuation in
//            self.makeAPIRequest(url: url, parameters: parameters, method: method, headers: headers) { (result: Result<T, NetworkError>) in
//                switch result {
//                case .success(let data):
//                    continuation.resume(returning: data)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//
//    // MARK: - API Request (Completion-based)
//    public func makeAPIRequest<T: Decodable>(
//        url: String,
//        parameters: [String: Any]?,
//        method: NetworkHelperHttpMethod = .post,
//        headers: HTTPHeaders,
//        completion: @escaping (Result<T, NetworkError>) -> Void
//    ) {
//        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
//            completion(.failure(.BAD_TOKEN))
//            return
//        }
//        
//        if NetworkReachability.shared.isNotReachable {
//            completion(.failure(.NO_INTERNET_CONNECTION))
//            return
//        }
//        
//        customSession
//            .request(url, method: method.method, parameters: parameters, encoding: JSONEncoding.default, headers: validatedHeaders)
//            .validate(statusCode: 200..<300)
//            .responseDecodable(of: T.self) { response in
//                self.handleResponse(response: response, completion: completion)
//            }
//    }
//
//    // MARK: - Upload API Request (Async)
//    public func makeUploadAPIRequestAsync<T: Decodable>(
//        url: String,
//        parameters: [String: Any]?,
//        fileData: [UploadableData]?,
//        method: NetworkHelperHttpMethod = .post,
//        headers: HTTPHeaders
//    ) async throws -> T {
//        return try await withCheckedThrowingContinuation { continuation in
//            self.makeUploadAPIRequest(url: url, parameters: parameters, fileData: fileData, method: method, headers: headers) { (result: Result<T, NetworkError>) in
//                switch result {
//                case .success(let data):
//                    continuation.resume(returning: data)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//
//    // MARK: - Upload API Request (Completion-based)
//    public func makeUploadAPIRequest<T: Decodable>(
//        url: String,
//        parameters: [String: Any]?,
//        fileData: [UploadableData]?,
//        method: NetworkHelperHttpMethod = .post,
//        headers: HTTPHeaders,
//        completion: @escaping (Result<T, NetworkError>) -> Void
//    ) {
//        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
//            completion(.failure(.BAD_TOKEN))
//            return
//        }
//        
//        if NetworkReachability.shared.isNotReachable {
//            completion(.failure(.NO_INTERNET_CONNECTION))
//            return
//        }
//        
//        guard let fileData = fileData, !fileData.isEmpty else {
//            completion(.failure(.UNHANDLED_ERROR(reason: "No file data provided")))
//            return
//        }
//        
//        customSession.upload(multipartFormData: { multipartFormData in
//            if let parameters = parameters {
//                for (key, value) in parameters {
//                    if let data = "\(value)".data(using: .utf8) {
//                        multipartFormData.append(data, withName: key)
//                    }
//                }
//            }
//            for file in fileData {
//                multipartFormData.append(file.fileData, withName: file.fileDataParamName, fileName: "file.jpg", mimeType: file.mimeType)
//            }
//        }, to: url, method: method.method, headers: validatedHeaders)
//        .validate(statusCode: 200..<300)
//        .responseDecodable(of: T.self) { response in
//            self.handleResponse(response: response, completion: completion)
//        }
//    }
//    
//    // MARK: - Response Handler
//    private func handleResponse<T: Decodable>(
//        response: DataResponse<T, AFError>,
//        completion: @escaping (Result<T, NetworkError>) -> Void
//    ) {
//        if response.error?.isServerTrustEvaluationError == true {
//            completion(.failure(.SSL_PINNING_FAILED))
//            return
//        }
//        
//        switch response.result {
//        case .success(let value):
//            completion(.success(value))
//        case .failure(let error):
//            let networkError = error.asNetworkError()
//            completion(.failure(networkError))
//        }
//    }
//
//    // MARK: - Authorization Check
//    private func addAuthorizationIfMissing(_ headers: HTTPHeaders) -> HTTPHeaders? {
//        var finalHeaders = headers
//        if let authorization = finalHeaders["Authorization"], authorization.starts(with: "Bearer ") {
//            let token = authorization.replacingOccurrences(of: "Bearer ", with: "").trimmingCharacters(in: .whitespaces)
//            if token.isEmpty, let storedToken = UserDefaults.standard.string(forKey: config.tokenStorageKey), !storedToken.isEmpty {
//                finalHeaders["Authorization"] = "Bearer \(storedToken)"
//            }
//        }
//        return finalHeaders
//    }
//}
//
//// MARK: - Retry and Throttle Interceptor
//public class RetryAndThrottleInterceptor: RequestInterceptor {
//    private let retryLimit: Int
//    private let exponentialBackoffBase: Double
//    private let exponentialBackoffScale: TimeInterval
//    private let throttleInterval: TimeInterval
//    
//    public init(retryLimit: Int, exponentialBackoffBase: Double, exponentialBackoffScale: TimeInterval, throttleInterval: TimeInterval) {
//        self.retryLimit = retryLimit
//        self.exponentialBackoffBase = exponentialBackoffBase
//        self.exponentialBackoffScale = exponentialBackoffScale
//        self.throttleInterval = throttleInterval
//    }
//    
//    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
//        let retryCount = request.retryCount
//        guard retryCount < retryLimit else {
//            return completion(.doNotRetry)
//        }
//        
//        let backoffDelay = pow(exponentialBackoffBase, Double(retryCount)) * exponentialBackoffScale
//        completion(.retryWithDelay(backoffDelay))
//    }
//}

// MARK: - Extension for AFError
extension AFError {
    func asNetworkError() -> NetworkError {
        switch self {
        case .responseSerializationFailed: return .DATA_PARSE_ERROR
        case .serverTrustEvaluationFailed: return .SSL_PINNING_FAILED
        case .sessionTaskFailed(let error as NSError) where error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut:
            return .TIMEOUT
        default: return .GENERAL_NETWORK_ERROR
        }
    }
}



public struct UploadableData: Codable {
    // MARK: - Properties
    public var fileData: Data
    public var fileDataParamName: String
    public var fileName: String
    public var mimeType: String
    public var fileType: String
    public var fileTypeParamName: String
    
    // MARK: - Computed Property
    public var fileTypeData: Data {
        return fileType.data(using: .utf8) ?? Data()
    }

    // MARK: - Init with optional parameters
    public init(fileData: Data,
                fileDataParamName: String = "File",
                fileName: String? = nil,
                mimeType: String? = nil,
                fileType: String,
                fileTypeParamName: String = "Type") {
        
        self.fileData = fileData
        self.fileDataParamName = fileDataParamName
        self.fileName = fileName ?? "file.\(fileData.fileExtension())"
        self.mimeType = mimeType ?? fileData.mimeType()
        self.fileType = fileType
        self.fileTypeParamName = fileTypeParamName
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


final public class NetworkReachability: ObservableObject {
    
    public  static let shared = NetworkReachability()
    
    private let reachability = NetworkReachabilityManager(host: "www.apple.com")!
    
    // Observable properties
    @Published public var isConnected: Bool = true
    @Published var isConnectedViaWiFi: Bool = false
    @Published var isConnectedViaCellular: Bool = false
    
    private init() {
        startListening()
    }
    
    /// Start observing reachability changes
    func startListening() {
        reachability.startListening { [weak self] status in
            self?.updateReachabilityStatus(status)
        }
    }
    
    /// Stop observing reachability changes
    func stopListening() {
        reachability.stopListening()
    }
    
    /// Update status based on connectivity
    private func updateReachabilityStatus(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch status {
        case .notReachable:
            DispatchQueue.main.async {
                self.isConnected = false
                self.isConnectedViaWiFi = false
                self.isConnectedViaCellular = false
            }
        case .reachable(let connection):
            DispatchQueue.main.async {
                self.isConnected = true
                switch connection {
                case .ethernetOrWiFi:
                    self.isConnectedViaWiFi = true
                    self.isConnectedViaCellular = false
                case .cellular:
                    self.isConnectedViaCellular = true
                    self.isConnectedViaWiFi = false
                @unknown default:
                    break
                }
                
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    /// returns if the current network status is reachable
    var isReachable: Bool {
        return reachability.isReachable
    }
     
     var isNotReachable: Bool {
         return !reachability.isReachable
     }
    
    deinit {
        stopListening()
    }
}
