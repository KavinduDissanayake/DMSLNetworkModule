import Testing
@testable import DMSLAnalytics

@Suite("Analytics Manager Test")
struct AnalyticsManagerTests {
    let analyticsManager = AnalyticsManagerMock()
    
    @Test func testCleverTapConfigure() {
        let testAccountID: String = "TestAccountID"
        let testToken: String = "12314"
        analyticsManager.configure(accountID: testAccountID, token: testToken, shouldEnableDebugLog: true)
        
        #expect(analyticsManager.configureCalled)
        #expect(analyticsManager.mockAccountID == testAccountID)
        #expect(analyticsManager.mockToken == testToken)
    }
    
    @Test func testCleverTapProfile() {
        let testUserProfile: Dictionary<String, Any> = ["Name":"Name", "userID": 123]
        analyticsManager.addUserProfile(profile: testUserProfile)
        
        #expect(analyticsManager.addUserProfileCalled)
        #expect(analyticsManager.mockUserProfile != nil)
    }
    
    @Test func testUpdateCleverTapProfile() {
        let testUserProfile: Dictionary<String, Any> = ["Name":"Name", "userID": 123]
        analyticsManager.updateUserProfile(profile: testUserProfile)
        
        #expect(analyticsManager.updateUserProfileCalled)
        #expect(analyticsManager.mockUserProfile != nil)
    }
    
    @Test func testCleverTapEvent() {
        let testEventName: String = "TestEvent"
        let testEventData: Dictionary<String, Any> = ["CT_LATITUDE":12212.213, "EVENT_PARAM": "Test"]
        
        analyticsManager.addEvent(eventName: testEventName, data: testEventData)
        
        #expect(analyticsManager.addEventCalled)
        #expect(analyticsManager.mockEventName == testEventName)
        #expect(analyticsManager.mockEvent != nil)
    }
}
