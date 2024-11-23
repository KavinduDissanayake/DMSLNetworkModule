//
//  CleverTapUseCase.swift
//  Analytics
//
//  Created by Sanush Radalage on 2024-04-03.
//

import Foundation
import CleverTapSDK

/*
 This class provides clevertap instance
 */
final class CleverTapProvider: AnalyticsProviderProtocol {
    
    init(){}
    
    func configureCleverTap(for accountID: String, with token: String, shouldEnableDebugLog: Bool) {
        CleverTap.setCredentialsWithAccountID(accountID, andToken: token)
        if shouldEnableDebugLog {
            CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        }
    }

    func addUserProfile(profile: Dictionary<String, Any>) {
        CleverTap.sharedInstance()?.onUserLogin(profile)
    }
    
    func updateUserProfile(profile: Dictionary<String, Any>) {
        CleverTap.sharedInstance()?.profilePush(profile)
    }
    
    func addEvent(eventName: String, data: [String : Any]) {
        CleverTap.sharedInstance()?.recordEvent(eventName, withProps: data)
    }
}
