//
//  NetworkManager.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-09.
//

import SwiftUI
import Alamofire
import LoggerModule

public struct APIResponse<T: Decodable>: Decodable {
    public let data: T
    public let headers: [AnyHashable: Any]?
    
    public init(data: T, headers: [AnyHashable: Any]?) {
        self.data = data
        self.headers = headers
    }
    
    // Decode only `data`, exclude `headers`
    public init(from decoder: Decoder) throws {
        self.data = try T(from: decoder)
        self.headers = nil // Headers are set manually at runtime
    }
}

//// MARK: - NetworkManager
public final class NetworkManager {
    
    public var customSession: Session
    private var config: NetworkConfiguration
    private var interceptor: RequestInterceptor
    
    // MARK: - Singleton
    public static var shared: NetworkManager = NetworkManager(configuration: NetworkConfiguration())
    
    // MARK: - Initializer with Config
    public init(configuration: NetworkConfiguration = NetworkConfiguration()) {
        self.config = configuration
        self.interceptor = RetryAndThrottleInterceptor(
            retryLimit: configuration.retryLimit,
            exponentialBackoffBase: configuration.exponentialBackoffBase,
            exponentialBackoffScale: configuration.exponentialBackoffScale,
            throttleInterval: configuration.throttleInterval
        )
        self.customSession = NetworkManager.configureCustomSession(
            retryPolicy: interceptor,
            enableSSLPinning: configuration.enableSSLPinning,
            pinnedDomains: configuration.pinnedDomains
        )
    }
    
    // MARK: - Configure the Shared Instance
    public static func configure(with configuration: NetworkConfiguration) {
        NetworkManager.shared = NetworkManager(configuration: configuration)
    }
    
    // MARK: - Configurable Custom Session
    public static func configureCustomSession(retryPolicy: RequestInterceptor, enableSSLPinning: Bool, pinnedDomains: [String: ServerTrustEvaluating]) -> Session {
        var serverTrustManager: ServerTrustManager?
        
        if enableSSLPinning && !pinnedDomains.isEmpty {
            serverTrustManager = ServerTrustManager(evaluators: pinnedDomains)
        }
        
        return Session(
            interceptor: retryPolicy,
            serverTrustManager: serverTrustManager
        )
    }
    
    // MARK: - API Request (Async)
    public func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod = .post,
        headers: HTTPHeaders,
        encoding: ParameterEncoding? = nil,
        includeHeaders: Bool = false // Add a flag to control header inclusion
    ) async throws -> T { // Return only data by default
        return try await withCheckedThrowingContinuation { continuation in
            self.makeAPIRequest(
                url: url,
                parameters: parameters,
                method: method,
                headers: headers,
                encoding: encoding
            ) { (result: Result<T, NetworkError>, responseHeaders) in
                switch result {
                case .success(let data):
                    if includeHeaders {
                        // Check if T is an APIResponse type
                        if let apiResponseType = T.self as? APIResponse<T>.Type {
                            // Safely initialize APIResponse with data and headers
                            if let apiResponse = apiResponseType.init(data: data, headers: responseHeaders) as? T {
                                continuation.resume(returning: apiResponse)
                            } else {
                                // Handle type mismatch
                                continuation.resume(throwing: NetworkError.UNHANDLED_ERROR(reason: "Failed to create APIResponse with the provided data and headers."))
                            }
                        } else {
                            // Handle the case where T is not APIResponse
                            continuation.resume(throwing: NetworkError.UNHANDLED_ERROR(reason: "Type mismatch: Expected APIResponse<T>, but received a different type."))
                        }
                    } else {
                        // Directly return the decoded data if headers are not needed
                        continuation.resume(returning: data)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - API Request (Completion-based)
    public func makeAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod = .post,
        headers: HTTPHeaders,
        encoding: ParameterEncoding? = nil,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    ) {
        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
            completion(.failure(.BAD_TOKEN),nil)
            return
        }
        
        if NetworkReachability.shared.isNotReachable {
            completion(.failure(.NO_INTERNET_CONNECTION),nil)
            return
        }
        
        // Determine encoding using the configuration
        let requestEncoding = encoding ?? config.determineEncoding(for: method)
        
        customSession
            .request(url, method: method.method, parameters: parameters, encoding: requestEncoding , headers: validatedHeaders)
            .validate(statusCode: 200..<300)
            .debugLog(using: config)
            .responseDecodable(of: T.self) { response in
                self.handleResponse(response: response, url: url, completion: completion)
            }
    }
    
    // MARK: - Upload API Request (Async)
    public func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod = .post,
        headers: HTTPHeaders,
        encoding: ParameterEncoding? = nil,
        progressHandler: ((Double) -> Void)? = nil,
        includeHeaders: Bool = false // Add flag to include headers
    ) async throws -> T { // Return only data by default
        return try await withCheckedThrowingContinuation { continuation in
            self.makeUploadAPIRequest(
                url: url,
                parameters: parameters,
                fileData: fileData,
                method: method,
                headers: headers,
                encoding: encoding,
                progressHandler: progressHandler
            ) { (result: Result<T, NetworkError>, responseHeaders) in
                switch result {
                case .success(let data):
                    if includeHeaders {
                        // Check if T is an APIResponse type
                        if let apiResponseType = T.self as? APIResponse<T>.Type {
                            // Safely initialize APIResponse with data and headers
                            if let apiResponse = apiResponseType.init(data: data, headers: responseHeaders) as? T {
                                continuation.resume(returning: apiResponse)
                            } else {
                                // Handle type mismatch
                                continuation.resume(throwing: NetworkError.UNHANDLED_ERROR(reason: "Failed to create APIResponse with the provided data and headers."))
                            }
                        } else {
                            // Handle the case where T is not APIResponse
                            continuation.resume(throwing: NetworkError.UNHANDLED_ERROR(reason: "Type mismatch: Expected APIResponse<T>, but received a different type."))
                        }
                    } else {
                        // Directly return the decoded data if headers are not needed
                        continuation.resume(returning: data)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Upload API Request (Completion-based)
    public func makeUploadAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod = .post,
        headers: HTTPHeaders,
        encoding: ParameterEncoding? = nil,
        progressHandler: ((Double) -> Void)? = nil,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    ) {
        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
            completion(.failure(.BAD_TOKEN),nil)
            return
        }
        
        if NetworkReachability.shared.isNotReachable {
            completion(.failure(.NO_INTERNET_CONNECTION),nil)
            return
        }
        
        guard let fileData = fileData, !fileData.isEmpty else {
            completion(.failure(.UNHANDLED_ERROR(reason: "No file data provided")),nil)
            return
        }
        
        customSession.upload(multipartFormData: { multipartFormData in
            if let parameters = parameters {
                for (key, value) in parameters {
                    if let data = "\(value)".data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
            for file in fileData {
                multipartFormData.append(file.fileData, withName: file.fileDataParamName, fileName: file.fileName, mimeType: file.mimeType)
                multipartFormData.append(file.fileTypeData, withName: file.fileType)
            }
        }, to: url, method: method.method, headers: validatedHeaders)
        .validate(statusCode: 200..<300)
        .uploadProgress { progressHandler?($0.fractionCompleted) }
        .responseDecodable(of: T.self) { response in
            self.handleResponse(response: response, url: url, completion: completion)
        }
    }
    
    // MARK: - Response Handler
    private func handleResponse<T: Decodable>(
        response: DataResponse<T, AFError>,
        url: String,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    ) {
        
        if response.error?.isServerTrustEvaluationError == true {
            StatusHandler.shared.processStatusCode(statusCode: -1, for: "SSL_PIN_FAILURE")
            completion(.failure(.SSL_PINNING_FAILED), nil)
            return
        }
        
        guard let statusCode = response.response?.statusCode else {
            completion(.failure(.GENERAL_NETWORK_ERROR), nil)
            return
        }
        
        if statusCode == 0 {
            completion(.failure(.GENERAL_NETWORK_ERROR), nil)
            return
        }
        // Add call back to handle each ruling with customized way
        StatusHandler.shared.processStatusCode(statusCode: statusCode, for: url)
        // Handle the response based on status code range (success or failure)
        switch response.result {
        case let .success(value):
            completion(.success(value), response.response?.allHeaderFields as? [AnyHashable: Any])
        case let .failure(afError):
            NetworkLogger.shared.logError(url: url, error: afError)
            switch statusCode {
            case 400:
                handleDecodedError(from: response.data, statusCode: statusCode, afError: afError, completion: completion)
            case 401, 403:
                completion(.failure(.UNAUTHENTICATED), nil)
            case 404:
                completion(.failure(.NETWORK_RESOURCE_NOT_FOUND), nil)
            case 426:
                completion(.failure(.UNHANDLED_ERROR(reason: "App update required")), nil)
            case 503:
                completion(.failure(.SERVER_OUTAGE), nil)
            case 500:
                handleDecodedError(from: response.data, statusCode: statusCode, afError: afError, completion: completion)
            case 500..<600:
                // Server-side errors (500-599)
                completion(.failure(.SERVER_SIDE_ERROR), nil)
            default:
                handleDecodedError(from: response.data, statusCode: statusCode, afError: afError, completion: completion)
            }
        }
    }
}

extension NetworkManager {
    // MARK: - Authorization Check
    func addAuthorizationIfMissing(_ headers: HTTPHeaders) -> HTTPHeaders? {
        var finalHeaders = headers
        if let authorization = finalHeaders["Authorization"], authorization.starts(with: "Bearer ") {
            let token = authorization.replacingOccurrences(of: "Bearer ", with: "").trimmingCharacters(in: .whitespaces)
            if token.isEmpty, let storedToken = UserDefaults.standard.string(forKey: config.tokenStorageKey), !storedToken.isEmpty {
                finalHeaders["Authorization"] = "Bearer \(storedToken)"
            }
        }
        return finalHeaders
    }
}

extension NetworkManager {
    func handleDecodedError<T: Decodable>(
        from data: Data?,
        statusCode: Int,
        afError: AFError,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    ) {
        // Check if we can decode the error message
        if let decodedError = decodeError(value: data) {
            var errorMessage: String?
            
            switch decodedError.errors {
            case .dictionary(let errorV2):
                errorMessage = errorV2.message ?? "oops_text"
                
            case .array(let errorV3Array):
                // Find the first valid error with both a code and message
                errorMessage = errorV3Array.first(where: { $0.code != nil && $0.message != nil })?.message ?? "oops_text"
                
            case nil, .some(.none):
                errorMessage = "oops_text"
            }
            
            // Use the error message extracted from the decoded error
            completion(.failure(.UNHANDLED_ERROR(reason: errorMessage ?? "oops_text")), nil)
        } else {
            //add this if some time backkend error not comming correclty
            if statusCode == 500{
                completion(.failure(.SERVER_SIDE_ERROR), nil)
                return
            }
            // Fallback to NetworkError if no decoded error
            let networkError = afError.asNetworkError()
            completion(.failure(networkError), nil)
        }
    }
}

extension NetworkManager {
    func decodeError(value: Data?) -> CommonError? {
        guard let data = value else {
            // Log the error using NetworkLogger for nil data
            Logger.shared.log("[🔴 ERROR] API RESPONSE: Provided value is nil")
            return nil
        }
        do {
            // Decode the data into CommonError
            let commonError = try JSONDecoder().decode(CommonError.self, from: data)
            return commonError
        } catch {
            // Log the decoding error using NetworkLogger
            Logger.shared.log("[🔴 ERROR] Error during decoding: \(error.localizedDescription)")
            return nil
        }
    }
}
