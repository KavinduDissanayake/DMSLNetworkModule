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
 You can customize retry limits, exponential backoff, SSL pinning, logging, and more.

 - Parameters:
   - retryLimit: Maximum number of retry attempts.
   - exponentialBackoffBase: Base value for exponential backoff retry.
   - exponentialBackoffScale: Time interval scaling factor for exponential backoff.
   - throttleInterval: Time to wait between retries.
   - enableLogging: Flag to enable or disable logging of network requests.
   - enableSSLPinning: Flag to enable or disable SSL pinning.
   - tokenStorageKey: Key for accessing tokens in UserDefaults.
   - pinnedDomains: SSL pinning configuration for specified domains.
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

    public init(
        retryLimit: Int = 3,
        exponentialBackoffBase: Double = 2.0,
        exponentialBackoffScale: TimeInterval = 1.5,
        throttleInterval: TimeInterval = 0.5,
        enableLogging: Bool = true,
        enableSSLPinning: Bool = false,
        tokenStorageKey: String = "server_token_new",
        pinnedDomains: [String: ServerTrustEvaluating] = [:]
    ) {
        self.retryLimit = retryLimit
        self.exponentialBackoffBase = exponentialBackoffBase
        self.exponentialBackoffScale = exponentialBackoffScale
        self.throttleInterval = throttleInterval
        self.enableLogging = enableLogging
        self.enableSSLPinning = enableSSLPinning
        self.tokenStorageKey = tokenStorageKey
        self.pinnedDomains = pinnedDomains
    }
}
