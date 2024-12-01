//
//  StatusHandlerRule.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//
import LoggerModule
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
        Logger.shared.log("[StatusHandler] No rule matched for status code: \(statusCode), URL: \(url)",type: .info)
    }
    
    
    /// Resets all the rules for clean test states.
      public func resetRules() {
          self.rules.removeAll()
      }

      /// Returns the current count of rules.
      public var rulesCount: Int {
          return self.rules.count
      }
}
