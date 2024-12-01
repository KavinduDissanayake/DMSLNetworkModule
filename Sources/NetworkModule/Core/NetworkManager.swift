//
//  NetworkManager.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-09.
//

import SwiftUI
import Alamofire
import LoggerModule


//// MARK: - NetworkManager
public final class NetworkManager: NetworkManagerProtocol {

    public var customSession: Session
    private var config: NetworkConfiguration

    // MARK: - Singleton
    public static var shared: NetworkManager = NetworkManager(configuration: NetworkConfiguration())

    // MARK: - Initializer with Config
    public init(configuration: NetworkConfiguration = NetworkConfiguration()) {
        self.config = configuration

        // Use the provided interceptor or default to RetryAndThrottleInterceptor
        let requestInterceptor = configuration.requestInterceptor ??
            RetryAndThrottleInterceptor(throttleInterval: configuration.throttleInterval)

        // Configure the session with provided or default response interceptor
        self.customSession = NetworkManager.configureCustomSession(
            requestInterceptor: requestInterceptor,
            responseInterceptor: configuration.responseInterceptor,
            enableSSLPinning: configuration.enableSSLPinning,
            pinnedDomains: configuration.pinnedDomains
        )
    }

    // MARK: - Configure the Shared Instance
    public static func configure(with configuration: NetworkConfiguration) {
        NetworkManager.shared = NetworkManager(configuration: configuration)
    }

    // MARK: - Configurable Custom Session
    public static func configureCustomSession(
        requestInterceptor: NetworkRequestInterceptor,
        responseInterceptor: NetworkResponseInterceptor?,
        enableSSLPinning: Bool,
        pinnedDomains: [String: ServerTrustEvaluating]
    ) -> Session {
        var eventMonitors: [EventMonitor] = []

        // Add response interceptor to the event monitors if provided
        if let responseInterceptor = responseInterceptor {
            eventMonitors.append(responseInterceptor)
        }

        // Configure server trust manager for SSL pinning if required
        var serverTrustManager: ServerTrustManager?
        if enableSSLPinning && !pinnedDomains.isEmpty {
            serverTrustManager = ServerTrustManager(evaluators: pinnedDomains)
        }

        // Return a custom session with the interceptors and monitors
        return Session(
            interceptor: requestInterceptor,
            serverTrustManager: serverTrustManager,
            eventMonitors: eventMonitors
        )
    }
}

// MARK: - API Request (Async)
extension NetworkManager {
    // MARK: - Basic Async API Request
    public func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod = .post,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.makeAPIRequest(url: url, parameters: parameters, method: method, headers: headers, encoding: encoding) { (result: Result<T, NetworkError>, _) in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Async API Request with Headers
    public func makeAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod = .post,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType? = nil
    ) async throws -> (T, [AnyHashable: Any]?) {
        return try await withCheckedThrowingContinuation { continuation in
            self.makeAPIRequest(url: url, parameters: parameters, method: method, headers: headers, encoding: encoding) { (result: Result<T, NetworkError>, headers) in
                switch result {
                case .success(let data):
                    continuation.resume(returning: (data, headers))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - API Request (Completion-Based)
extension NetworkManager {
    public func makeAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: NetworkHttpMethod = .post,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType? = nil,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    ) {
        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
            completion(.failure(.BAD_TOKEN), nil)
            return
        }
        
        if NetworkReachability.shared.isNotReachable {
            completion(.failure(.NO_INTERNET_CONNECTION), nil)
            return
        }
        
        let requestEncoding = encoding?.encoding ?? config.determineEncoding(for: method).encoding
        
        customSession
            .request(url, method: method.method, parameters: parameters, encoding: requestEncoding, headers: validatedHeaders.toHTTPHeaders())
            .validate(statusCode: 200..<300)
            .debugLog(using: config)
            .responseDecodable(of: T.self) { response in
                self.handleResponse(response: response, url: url, completion: completion)
            }
    }
}

// MARK: - Upload API Request (Async)
extension NetworkManager {
    // MARK: - Basic Async Upload
    public func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod = .post,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType? = nil,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            self.makeUploadAPIRequest(
                url: url,
                parameters: parameters,
                fileData: fileData,
                method: method,
                headers: headers,
                encoding: encoding,
                progressHandler: progressHandler
            ) { (result: Result<T, NetworkError>, _) in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Async Upload with Headers
    public func makeUploadAPIRequestAsync<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod = .post,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType? = nil,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> (T, [AnyHashable: Any]?) {
        return try await withCheckedThrowingContinuation { continuation in
            self.makeUploadAPIRequest(
                url: url,
                parameters: parameters,
                fileData: fileData,
                method: method,
                headers: headers,
                encoding: encoding,
                progressHandler: progressHandler
            ) { (result: Result<T, NetworkError>, headers) in
                switch result {
                case .success(let data):
                    continuation.resume(returning: (data, headers))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Upload API Request (Completion-Based)
extension NetworkManager {
    public func makeUploadAPIRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        fileData: [UploadableData]?,
        method: NetworkHttpMethod = .post,
        headers: NetworkHeaders,
        encoding: NetworkEncodingType? = nil,
        progressHandler: ((Double) -> Void)? = nil,
        completion: @escaping (Result<T, NetworkError>, [AnyHashable: Any]?) -> Void
    ) {
        guard let validatedHeaders = addAuthorizationIfMissing(headers) else {
            completion(.failure(.BAD_TOKEN), nil)
            return
        }
        
        if NetworkReachability.shared.isNotReachable {
            completion(.failure(.NO_INTERNET_CONNECTION), nil)
            return
        }
        
        guard let fileData = fileData, !fileData.isEmpty else {
            completion(.failure(.UNHANDLED_ERROR(reason: "No file data provided")), nil)
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
        }, to: url, method: method.method, headers: validatedHeaders.toHTTPHeaders())
        .validate(statusCode: 200..<300)
        .uploadProgress { progressHandler?($0.fractionCompleted) }
        .responseDecodable(of: T.self) { response in
            self.handleResponse(response: response, url: url, completion: completion)
        }
    }
}


// MARK: - Authorization Check
extension NetworkManager {
    /// Ensures that the Authorization header is present and valid.
    /// If the Authorization token is empty, attempts to retrieve it from UserDefaults.
    /// - Parameter headers: The `NetworkHeaders` object to validate and modify.
    /// - Returns: The validated `NetworkHeaders` object, or `nil` if validation fails.
    func addAuthorizationIfMissing(_ headers: NetworkHeaders) -> NetworkHeaders? {
        var finalHeaders = headers

        if let authorization = finalHeaders.value(for: "Authorization"), authorization.starts(with: "Bearer ") {
            let token = authorization.replacingOccurrences(of: "Bearer ", with: "").trimmingCharacters(in: .whitespaces)
            if token.isEmpty, let storedToken = UserDefaults.standard.string(forKey: config.tokenStorageKey), !storedToken.isEmpty {
                finalHeaders.add("Bearer \(storedToken)", for: "Authorization")
            }
        }

        return finalHeaders
    }
}

// MARK: - Error Handling
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
            Logger.shared.log("API RESPONSE: Provided value is nil",type: .error)
            return nil
        }
        do {
            // Decode the data into CommonError
            let commonError = try JSONDecoder().decode(CommonError.self, from: data)
            return commonError
        } catch {
            // Log the decoding error using NetworkLogger
            Logger.shared.log("Error during decoding: \(error.localizedDescription)",type: .error)
            return nil
        }
    }
}


// MARK: - Response Handling
extension NetworkManager {
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
