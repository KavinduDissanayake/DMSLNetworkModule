//
//  CleverTapMockService.swift
//  DMSLAnalytics
//
//  Created by Rumeth Randombage on 2024-10-15.
//
@testable import DMSLAnalytics

public class AnalyticsManagerMock: AnalyticsManagerProtocol {
    
    //Base functionality
    var configureCalled: Bool = false
    var addUserProfileCalled: Bool = false
    var updateUserProfileCalled: Bool = false
    var addEventCalled: Bool = false
    
    //Test Properties
    var mockAccountID: String?
    var mockToken: String?
    var mockUserProfile: Dictionary<String, Any>?
    var mockEventName: String?
    var mockEvent: Dictionary<String, Any>?
    
    public init() {}   
    
    public func configure(accountID: String, token: String, shouldEnableDebugLog: Bool) {
        configureCalled = true
        mockAccountID = accountID
        mockToken = token
    }
    
    public func addUserProfile(profile: Dictionary<String, Any>) {
        addUserProfileCalled = true
        mockUserProfile = profile
    }
    
    public func updateUserProfile(profile: Dictionary<String, Any>) {
        updateUserProfileCalled = true
        mockUserProfile = profile
    }
    
    public func addEvent(eventName: String, data: [String : Any]) {
        addEventCalled = true
        mockEventName = eventName
        mockEvent = data
    }
}
