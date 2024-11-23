//
//  AnalyticsProtocol.swift
//  Analytics
//
//  Created by Sanush Radalage on 2024-04-03.
//

import Foundation

protocol AnalyticsProviderProtocol {
    func configureCleverTap(for: String, with: String, shouldEnableDebugLog: Bool)
    func addUserProfile(profile: Dictionary<String, Any>)
    func updateUserProfile(profile: Dictionary<String, Any>)
    func addEvent(eventName: String, data: [String : Any])
}
