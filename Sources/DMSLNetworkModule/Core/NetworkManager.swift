//
//  NetworkManager.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-09.
//

import SwiftUI
import Alamofire

//// MARK: - NetworkHelper
public final class NetworkHelper {
    
    public var customSession: Session
    private var config: NetworkConfiguration
    private var interceptor: RequestInterceptor
    
    // MARK: - Singleton
    public static var shared: NetworkHelper = NetworkHelper(configuration: NetworkConfiguration())
    
    // MARK: - Initializer with Config
    public init(configuration: NetworkConfiguration = NetworkConfiguration()) {
        self.config = configuration
        self.interceptor = RetryAndThrottleInterceptor(
            retryLimit: configuration.retryLimit,
            exponentialBackoffBase: configuration.exponentialBackoffBase,
            exponentialBackoffScale: configuration.exponentialBackoffScale,
            throttleInterval: configuration.throttleInterval
        )
        self.customSession = NetworkHelper.configureCustomSession(
            retryPolicy: interceptor,
            enableSSLPinning: configuration.enableSSLPinning,
            pinnedDomains: configuration.pinnedDomains
        )
    }
    
    // MARK: - Configure the Shared Instance
    public static func configure(with configuration: NetworkConfiguration) {
        NetworkHelper.shared = NetworkHelper(configuration: configuration)
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
        headers: HTTPHeaders
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.makeAPIRequest(url: url, parameters: parameters, method: method, headers: headers) { (result: Result<T, NetworkError>) in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
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
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
            completion(.failure(.BAD_TOKEN))
            return
        }
        
        if NetworkReachability.shared.isNotReachable {
            completion(.failure(.NO_INTERNET_CONNECTION))
            return
        }
        
        
        // Log request details
        if config.enableLogging {
            NetworkLogger.shared.logRequest(url: url, method: method.method.rawValue, headers: headers.dictionary, body: parameters)
        }
        
        customSession
            .request(url, method: method.method, parameters: parameters, encoding: JSONEncoding.default, headers: validatedHeaders)
            .validate(statusCode: 200..<300)
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
        headers: HTTPHeaders
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.makeUploadAPIRequest(url: url, parameters: parameters, fileData: fileData, method: method, headers: headers) { (result: Result<T, NetworkError>) in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
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
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
            completion(.failure(.BAD_TOKEN))
            return
        }
        
        if NetworkReachability.shared.isNotReachable {
            completion(.failure(.NO_INTERNET_CONNECTION))
            return
        }
        
        guard let fileData = fileData, !fileData.isEmpty else {
            completion(.failure(.UNHANDLED_ERROR(reason: "No file data provided")))
            return
        }
        
        
        // Log request details
        if config.enableLogging {
            NetworkLogger.shared.logRequest(url: url, method: method.method.rawValue, headers: headers.dictionary, body: parameters)
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
                multipartFormData.append(file.fileData, withName: file.fileDataParamName, fileName: "file.jpg", mimeType: file.mimeType)
            }
        }, to: url, method: method.method, headers: validatedHeaders)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: T.self) { response in
            self.handleResponse(response: response, url: url, completion: completion)
        }
    }
    
    // MARK: - Response Handler
    private func handleResponse<T: Decodable>(
        response: DataResponse<T, AFError>,
        url: String,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        
        if response.error?.isServerTrustEvaluationError == true {
            StatusHandler.shared.processStatusCode(statusCode: -1, for: "SSL_PIN_FAILURE")
            completion(.failure(.SSL_PINNING_FAILED))
            return
        }
        
        
        guard let statusCode = response.response?.statusCode else {
            completion(.failure(.GENERAL_NETWORK_ERROR)) // Handle missing status code
            return
        }
        
        if statusCode == 0 {
            completion(.failure(.GENERAL_NETWORK_ERROR)) // Handle status code 0 explicitly
            return
        }
        
        // Handle the response based on status code range (success or failure)
        switch response.result {
        case let .success(value):
            completion(.success(value))
        case let .failure(afError):
            NetworkLogger.shared.logError(url: url, error: afError)
            switch statusCode {
            case 400:
                handleDecodedError(from: response.data, statusCode: statusCode, afError: afError, completion: completion)
            case 401:
                completion(.failure(.UNAUTHENTICATED))
            case 403:
                completion(.failure(.UNAUTHENTICATED))
            case 404:
                completion(.failure(.NETWORK_RESOURCE_NOT_FOUND))
            case 426:
                completion(.failure(.UNHANDLED_ERROR(reason: "App update required")))
            case 503:
                completion(.failure(.SERVER_OUTAGE))
            case 500:
                handleDecodedError(from: response.data, statusCode: statusCode, afError: afError, completion: completion)
            case 500..<600:
                // Server-side errors (500-599)
                completion(.failure(.SERVER_SIDE_ERROR))
            default:
                handleDecodedError(from: response.data, statusCode: statusCode, afError: afError, completion: completion)
            }
        }
    }
}

extension NetworkHelper {
    // MARK: - Authorization Check
    private func addAuthorizationIfMissing(_ headers: HTTPHeaders) -> HTTPHeaders? {
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



extension NetworkHelper {
    func handleDecodedError<T: Decodable>(
        from data: Data?,
        statusCode: Int,
        afError: AFError,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // Check if we can decode the error message
        if let decodedError = decodeError(data: data) {
            var errorMessage: String?
            
            switch decodedError.errors {
            case .dictionary(let errorV2):
                errorMessage = errorV2.message ?? "400 Error"
                
            case .array(let errorV3Array):
                // Find the first valid error with both a code and message
                errorMessage = errorV3Array.first(where: { $0.code != nil && $0.message != nil })?.message ?? "oops_text"
                
            case nil, .some(.none):
                errorMessage = "oops_text"
            }

            // Use the error message extracted from the decoded error
            completion(.failure(.UNHANDLED_ERROR(reason: errorMessage ?? "400 Error")))
        } else {
            // Fallback to NetworkError if no decoded error
            let networkError = afError.asNetworkError()
            completion(.failure(networkError))
        }
    }
}

extension NetworkHelper {
    func decodeError(data: Data?) -> CommonError? {
        guard let data = data else {
            // Log the error using NetworkLogger for nil data
            NetworkLogger.shared.log("[🔴 ERROR] API RESPONSE: Provided value is nil")
            return nil
        }
        
        do {
            // Decode the data into CommonError
            let commonError = try JSONDecoder().decode(CommonError.self, from: data)
            return commonError
        } catch {
            // Log the decoding error using NetworkLogger
            NetworkLogger.shared.log("[🔴 ERROR] Error during decoding: \(error.localizedDescription)")
            return nil
        }
    }
}
