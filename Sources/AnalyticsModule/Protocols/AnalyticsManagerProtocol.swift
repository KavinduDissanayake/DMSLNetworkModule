//
//  AnalyticsManagerProtocol.swift
//  Analytics
//
//  Created by Sanush Radalage on 2024-04-05.
//

import Foundation

public protocol AnalyticsManagerProtocol {
    /// Implement this within the AppDelegate before proceeding with recording events/ profile data
    func configure(accountID: String, token: String, shouldEnableDebugLog: Bool)
    func addUserProfile(profile: Dictionary<String, Any>)
    func updateUserProfile(profile: Dictionary<String, Any>)
    func addEvent(eventName: String, data: [String : Any])
}
