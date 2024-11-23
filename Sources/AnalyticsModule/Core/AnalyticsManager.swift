//
//  AnalyticsManager.swift
//  Analytics
//
//  Created by Sanush Radalage on 2024-04-03.
//

import Foundation

public final class AnalyticsManager: AnalyticsManagerProtocol {

    // Singleton instance
    public static let shared = AnalyticsManager()

    // The current provider for analytics
    private var currentProvider: AnalyticsProviderProtocol?

    // Private initializer to prevent instantiation from other classes
    private init(provider: AnalyticsProviderProtocol = CleverTapProvider()) {
        currentProvider = provider
    }
    
    //Initialize CT with a given accountID and Token
    public func configure(accountID: String, token: String, shouldEnableDebugLog: Bool = false) {
        guard let provider = currentProvider else {
            print("No analytics provider initialized!")
            return
        }
        provider.configureCleverTap(for: accountID, with: token, shouldEnableDebugLog: shouldEnableDebugLog)
    }

    // Function to add user profile
    public func addUserProfile(profile: Dictionary<String, Any>) {
        guard let provider = currentProvider else {
            print("No analytics provider initialized!")
            return
        }
        provider.addUserProfile(profile: profile)
    }

    // Function to add event
    public func addEvent(eventName: String, data: [String : Any]) {
        guard let provider = currentProvider else {
            print("No analytics provider initialized!")
            return
        }
        provider.addEvent(eventName: eventName, data: data)
    }

    // Function to update user profile
    public func updateUserProfile(profile: Dictionary<String, Any>) {
        guard let provider = currentProvider else {
            print("No analytics provider initialized!")
            return
        }
        provider.updateUserProfile(profile: profile)
    }
}
