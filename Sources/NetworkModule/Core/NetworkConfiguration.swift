//
//  NetworkConfiguration.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//

import Foundation
import Alamofire

/**
 `NetworkConfiguration` is a struct that holds the network configuration options for the `NetworkHelper`.
 You can customize retry limits, exponential backoff, SSL pinning, logging, encoding, and more.
 
 - Parameters:
 - requestInterceptor: Optional custom request interceptor for modifying or retrying requests.
 - responseInterceptor: Optional custom response interceptor for handling or monitoring responses.
 - throttleInterval: Time to wait between retries.
 - enableLogging: Flag to enable or disable logging of network requests.
 - enableSSLPinning: Flag to enable or disable SSL pinning.
 - tokenStorageKey: Key for accessing tokens in UserDefaults.
 - pinnedDomains: SSL pinning configuration for specified domains.
 - loggerConfig: Configuration for advanced logging.
 - defaultEncoding: Default parameter encoding for HTTP methods.
 - methodEncodingMap: A dictionary that maps HTTP methods to their respective parameter encodings.
 */
public struct NetworkConfiguration {
    public var requestInterceptor: NetworkRequestInterceptor?
    public var responseInterceptor: NetworkResponseInterceptor?
    public var throttleInterval: TimeInterval
    public var enableLogging: Bool
    public var enableSSLPinning: Bool
    public var tokenStorageKey: String
    public var pinnedDomains: [String: ServerTrustEvaluating]
    public var loggerConfig: LoggerConfig
    public var defaultEncoding: NetworkEncodingType
    public var methodEncodingMap: [NetworkHttpMethod: NetworkEncodingType]
    
    // MARK: - Initializer
    public init(
        requestInterceptor: NetworkRequestInterceptor? = nil,
        responseInterceptor: NetworkResponseInterceptor? = nil,
        throttleInterval: TimeInterval = 0.5,
        enableLogging: Bool = true,
        enableSSLPinning: Bool = false,
        tokenStorageKey: String = "server_token_new",
        pinnedDomains: [String: ServerTrustEvaluating] = [:],
        loggerConfig: LoggerConfig = .default,
        defaultEncoding: NetworkEncodingType = NetworkEncodingType.jsonEncoded,
        methodEncodingMap: [NetworkHttpMethod: NetworkEncodingType] = [
            .get: .urlEncoded,
            .delete: .urlEncoded,
            .post: .jsonEncoded,
            .put: .jsonEncoded
        ]
    ) {
        self.requestInterceptor = requestInterceptor
        self.responseInterceptor = responseInterceptor
        self.throttleInterval = throttleInterval
        self.enableLogging = enableLogging
        self.enableSSLPinning = enableSSLPinning
        self.tokenStorageKey = tokenStorageKey
        self.pinnedDomains = pinnedDomains
        self.loggerConfig = loggerConfig
        self.defaultEncoding = defaultEncoding
        self.methodEncodingMap = methodEncodingMap
    }
    
    // MARK: - Encoding Determination Logic
    /**
     Determines the parameter encoding for a given HTTP method.
     
     - Parameter method: The HTTP method for which to determine the encoding.
     - Returns: The parameter encoding for the specified method.
     */
    public func determineEncoding(for method: NetworkHttpMethod) -> NetworkEncodingType {
        return methodEncodingMap[method] ?? defaultEncoding
    }
}

// MARK: - Logger Configuration
public struct LoggerConfig {
    public var logRequestHeaders: Bool
    public var logRequestBody: Bool
    public var logResponseHeaders: Bool
    public var logResponseBody: Bool
    public var logStatusCode: Bool

    // MARK: - Public Initializer
    public init(
        logRequestHeaders: Bool = true,
        logRequestBody: Bool = true,
        logResponseHeaders: Bool = true,
        logResponseBody: Bool = true,
        logStatusCode: Bool = true
    ) {
        self.logRequestHeaders = logRequestHeaders
        self.logRequestBody = logRequestBody
        self.logResponseHeaders = logResponseHeaders
        self.logResponseBody = logResponseBody
        self.logStatusCode = logStatusCode
    }

    // MARK: - Default Configuration
    public static let `default` = LoggerConfig()
}
