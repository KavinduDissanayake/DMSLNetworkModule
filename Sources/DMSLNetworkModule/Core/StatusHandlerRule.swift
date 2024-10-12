//
//  StatusHandlerRule.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//

import Foundation

/// A struct that defines rules for handling specific HTTP status codes based on URL patterns.
public struct StatusHandlerRule {
    let statusCode: Int
    let urlPattern: String
    let handler: (String) -> Void
    
    public init(statusCode: Int, urlPattern: String, handler: @escaping (String) -> Void) {
        self.statusCode = statusCode
        self.urlPattern = urlPattern
        self.handler = handler
    }
}

/// A class that handles HTTP status codes based on a set of rules.
public final class StatusHandler {

    // Shared instance for global access
    public static let shared = StatusHandler()
    
    // Stores all the rules
    private var rules: [StatusHandlerRule] = []
    
    // Private initializer to prevent external initialization
    private init() {}

    /// Add a new rule for handling a status code and URL pattern.
    public func addRule(_ rule: StatusHandlerRule) {
        rules.append(rule)
    }
    
    /// Process the status code for the given URL, matching against all registered rules.
    public func processStatusCode(statusCode: Int, for url: String) {
        for rule in rules {
            if statusCode == rule.statusCode && url.contains(rule.urlPattern) {
                rule.handler(url)
                return
            }
        }
        // No matching rule found
        print("[StatusHandler] No rule matched for status code: \(statusCode), URL: \(url)")
    }
}
//
//// Define your specific rules when NetworkHelper is initialized
//public func configureStatusHandler() {
//    let statusStore = NetworkResponseStatusStore.shared
//    
//    // Rule for handling token blacklist (403)
//    StatusHandler.shared.addRule(
//        StatusHandlerRule(statusCode: 403, urlPattern: "/token/blacklist") { url in
//            statusStore.updateIsTokenBlacklistedStatus(with: true, apiWhereTokenWasBlacklisted: url)
//        }
//    )
//    
//    // Rule for handling app version update (426)
//    StatusHandler.shared.addRule(
//        StatusHandlerRule(statusCode: 426, urlPattern: "/version/check") { _ in
//            statusStore.updateIsNewAppVersionAvailableStatus(with: true)
//        }
//    )
//
//    // Rule for handling service outage (503)
//    StatusHandler.shared.addRule(
//        StatusHandlerRule(statusCode: 503, urlPattern: "/service/outage") { _ in
//            statusStore.updateServiceOutageStatus(reported: true)
//        }
//    )
//
//    // Rule for resetting service outage status (200 OK on specific URLs)
//    StatusHandler.shared.addRule(
//        StatusHandlerRule(statusCode: 200, urlPattern: "v4.0/passenger/geo/configurations") { _ in
//            statusStore.updateServiceOutageStatus(reported: false)
//        }
//    )
//
//    StatusHandler.shared.addRule(
//        StatusHandlerRule(statusCode: 200, urlPattern: "v3.0/upfront/price") { _ in
//            statusStore.dissableBookNowAndBookLator = false
//        }
//    )
//    
//    // Add more rules as needed...
//}
