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
   - retryLimit: Maximum number of retry attempts.
   - exponentialBackoffBase: Base value for exponential backoff retry.
   - exponentialBackoffScale: Time interval scaling factor for exponential backoff.
   - throttleInterval: Time to wait between retries.
   - enableLogging: Flag to enable or disable logging of network requests.
   - enableSSLPinning: Flag to enable or disable SSL pinning.
   - tokenStorageKey: Key for accessing tokens in UserDefaults.
   - pinnedDomains: SSL pinning configuration for specified domains.
   - loggerConfig: Configuration for advanced logging.
   - methodEncodingMap: A dictionary that maps HTTP methods to their respective parameter encodings.
 */
public struct NetworkConfiguration {
    public var retryLimit: Int
    public var exponentialBackoffBase: Double
    public var exponentialBackoffScale: TimeInterval
    public var throttleInterval: TimeInterval
    public var enableLogging: Bool
    public var enableSSLPinning: Bool
    public var tokenStorageKey: String
    public var pinnedDomains: [String: ServerTrustEvaluating]
    public var loggerConfig: LoggerConfig
    public var defaultEncoding: ParameterEncoding
    public var methodEncodingMap: [NetworkHttpMethod: ParameterEncoding]

    // MARK: - Initializer
    public init(
        retryLimit: Int = 3,
        exponentialBackoffBase: Double = 2.0,
        exponentialBackoffScale: TimeInterval = 1.5,
        throttleInterval: TimeInterval = 0.5,
        enableLogging: Bool = true,
        enableSSLPinning: Bool = false,
        tokenStorageKey: String = "server_token_new",
        pinnedDomains: [String: ServerTrustEvaluating] = [:],
        loggerConfig: LoggerConfig = .default,
        defaultEncoding: ParameterEncoding = JSONEncoding.default,
        methodEncodingMap: [NetworkHttpMethod: ParameterEncoding] = [
            .get: JSONEncoding.default,
            .delete: JSONEncoding.default,
            .post: JSONEncoding.default,
            .put: JSONEncoding.default
        ] // Default method-encoding mapping
    ) {
        self.retryLimit = retryLimit
        self.exponentialBackoffBase = exponentialBackoffBase
        self.exponentialBackoffScale = exponentialBackoffScale
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
     Returns the encoding for the specified HTTP method. Uses the methodEncodingMap for customization.
     
     - Parameter method: The HTTP method for which to determine the encoding.
     - Returns: The corresponding ParameterEncoding for the given method.
     */
    public func determineEncoding(for method: NetworkHttpMethod) -> ParameterEncoding {
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

    public static let `default` = LoggerConfig(
        logRequestHeaders: true,
        logRequestBody: true,
        logResponseHeaders: true,
        logResponseBody: true,
        logStatusCode: true
    )
}
