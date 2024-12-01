//
//  NetworkHelperTests.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-13.
//

import XCTest
import Alamofire
@testable import NetworkModule

struct InvalidData: Encodable, Decodable {}

// MARK: - Test Models
struct TestModel: Decodable {
    struct Data: Decodable {
        let id: Int
        let name: String
    }
    let message: String
    let data: Data
}

struct MockCommonError {
    static func validDictionaryError() -> CommonError {
        return CommonError(errors: .dictionary(MockErrorsV2.validDictionary()))
    }
    
    static func validArrayError() -> CommonError {
        return CommonError(errors: .array(MockErrorsV2.validArray()))
    }
}

struct MockErrorsV2 {
    static func validDictionary() -> ErrorsV2 {
        return ErrorsV2(code: 400, message: "Dictionary Error Occurred")
    }
    
    static func validArray() -> [ErrorV3] {
        return [
            ErrorV3(code: "1001", correlationID: "abc123", developerMessage: "Dev message", message: "Array Error Occurred")
        ]
    }
}


// MARK: - NetworkHelperTests
final class NetworkHelperTests: XCTestCase {
    
    var networkHelper: NetworkManager!
    var mockSession: Session!
    
    override func setUp() {
        super.setUp()
        
        // Setup mock session with MockURLProtocol
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = Session(configuration: configuration)
        
        // Initialize network helper with the mock session
        networkHelper = NetworkManager()
        networkHelper.customSession = mockSession
        
        UserDefaults.standard.removeObject(forKey: "server_token_new")
    }
    
    override func tearDown() {
        super.tearDown()
        MockURLProtocol.reset()
        networkHelper = nil
    }
    
}
//
// MARK: - Async/await API Request Tests
extension NetworkHelperTests {
    // MARK: - SSL Pinning Failure Test
    func testSSLpinningFailure() async throws {
        // Simulate an SSL pinning error
        let sslError = NSError(domain: NSURLErrorDomain, code: NSURLErrorServerCertificateUntrusted, userInfo: nil)
        MockURLProtocol.stubError = sslError
        
        do {
            let _: TestModel = try await networkHelper.makeAPIRequestAsync(
                url: "https://example.com",
                parameters: nil,
                method: .get,
                headers: NetworkHeaders()
            )
            XCTFail("Expected SSL Pinning failure, but the request succeeded")
        } catch let error as NetworkError {
            // For mock tests, we expect SSL Pinning to fail. However, in live apps, the error might fall back to GENERAL_NETWORK_ERROR.
            if error == .SSL_PINNING_FAILED {
                XCTAssertEqual(error, .SSL_PINNING_FAILED, "Expected SSL Pinning error.")
            } else {
                XCTAssertEqual(error, .GENERAL_NETWORK_ERROR, "Expected General Network Error if the mock is not handled.")
            }
        }
    }
    
    func testMakeAPIRequestAsync_Success() async throws {
        let mockResponseData = """
        {
            "message": "Success",
            "data": { "id": 1, "name": "Test" }
        }
        """.data(using: .utf8)!
        MockURLProtocol.stubResponseData = mockResponseData
        MockURLProtocol.stubResponseStatusCode = 200
        
        let result: TestModel = try await networkHelper.makeAPIRequestAsync(
            url: "https://example.com/api/test",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        )
        
        XCTAssertEqual(result.data.name, "Test")
        XCTAssertEqual(result.data.id, 1)
    }
    
    func testMakeAPIRequestAsync_NotFound() async throws {
        MockURLProtocol.stubResponseStatusCode = 404
        
        do {
            let _: TestModel = try await networkHelper.makeAPIRequestAsync(
                url: "https://example.com/api/test",
                parameters: nil,
                method: .get,
                headers: NetworkHeaders()
            )
            XCTFail("Expected 404 Not Found error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .NETWORK_RESOURCE_NOT_FOUND)
        }
    }
    
    
    func testMakeAPIRequestAsync_Forbidden() async throws {
        MockURLProtocol.stubResponseStatusCode = 403
        
        do {
            let _: TestModel = try await networkHelper.makeAPIRequestAsync(
                url: "https://example.com/api/test",
                parameters: nil,
                method: .get,
                headers: NetworkHeaders()
            )
            XCTFail("Expected 403 Forbidden error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .UNAUTHENTICATED)
        }
    }
    
    func testMakeAPIRequestAsync_ServerError() async throws {
        MockURLProtocol.stubResponseStatusCode = 500
        
        do {
            let _: TestModel = try await networkHelper.makeAPIRequestAsync(
                url: "https://example.com/api/test",
                parameters: nil,
                method: .get,
                headers: NetworkHeaders()
            )
            XCTFail("Expected 500 Server Error")
        } catch let error as NetworkError {
            //Same as server error
            XCTAssertEqual(error, .SERVER_SIDE_ERROR)
        }
    }
    
    // MARK: - File Upload Async Tests
    func testMakeUploadAPIRequestAsync_Success() async throws {
        let mockResponseData = """
        {
            "message": "File uploaded",
            "data": { "id": 2, "name": "UploadTest" }
        }
        """.data(using: .utf8)!
        MockURLProtocol.stubResponseData = mockResponseData
        MockURLProtocol.stubResponseStatusCode = 200
        
        let mockFileData = UploadableData(
            fileData: Data(),
            fileDataParamName: "file",
            fileName: "test.jpg",
            mimeType: "image/jpeg"
        )
        
        let result: TestModel = try await networkHelper.makeUploadAPIRequestAsync(
            url: "https://example.com/api/upload",
            parameters: nil,
            fileData: [mockFileData],
            method: .post,
            headers: NetworkHeaders()
        )
        
        XCTAssertEqual(result.data.name, "UploadTest")
    }
    
    func testMakeUploadAPIRequestAsync_MissingMIMEType() async throws {
        let mockFileData = UploadableData(
            fileData: Data(),
            fileDataParamName: "file",
            fileName: "test.jpg",
            mimeType: "" // Missing MIME type
        )
        
        do {
            let _: TestModel = try await networkHelper.makeUploadAPIRequestAsync(
                url: "https://example.com/api/upload",
                parameters: nil,
                fileData: [mockFileData],
                method: .post,
                headers: NetworkHeaders()
            )
            XCTFail("Expected error for missing MIME type")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .UNHANDLED_ERROR(reason: "We encountered an issue processing the server\'s response. Please try again."))
        }
    }
    
}


// MARK: -WithSuccessWithHeaders
extension NetworkHelperTests {
    func testMakeAPIRequestAsync_SuccessWithHeaders() async throws {
        // Mocking response headers with [String: String]
        let mockHeaders: [String: String] = [
            "Content-Type": "application/json",
            "Custom-Header": "HeaderValue"
        ]
        
        let mockResponseData = """
        {
            "message": "Success",
            "data": { "id": 1, "name": "Test" }
        }
        """.data(using: .utf8)!
        MockURLProtocol.stubResponseData = mockResponseData
        MockURLProtocol.stubResponseStatusCode = 200
        MockURLProtocol.stubResponseHeaders = mockHeaders // Stubbing response headers
        
        // Make the API request
        let (result, headers): (TestModel, [AnyHashable: Any]?) = try await networkHelper.makeAPIRequestAsync(
            url: "https://example.com/api/test",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        )

        // Access data
        XCTAssertEqual(result.data.name, "Test")
        XCTAssertEqual(result.data.id, 1)

        // Access headers
        if let headers = headers {
            XCTAssertEqual(headers["Content-Type"] as? String, "application/json")
            XCTAssertEqual(headers["Custom-Header"] as? String, "HeaderValue")
        }
    }
}

// MARK: - Traditional Callback API Request Tests
extension NetworkHelperTests {
    // MARK: - SSL Pinning Failure Test (Callback Version)
    func testSSLpinningFailureCallback() {
        // Simulate an SSL pinning error
        let sslError = NSError(domain: NSURLErrorDomain, code: NSURLErrorServerCertificateUntrusted, userInfo: nil)
        MockURLProtocol.stubError = sslError
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.makeAPIRequest(
            url: "https://example.com",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            switch result {
            case .failure(let error):
                // For mock tests, we expect SSL Pinning to fail. However, in live apps, the error might fall back to GENERAL_NETWORK_ERROR.
                if error == .SSL_PINNING_FAILED {
                    XCTAssertEqual(error, .SSL_PINNING_FAILED, "Expected SSL Pinning error.")
                } else {
                    XCTAssertEqual(error, .GENERAL_NETWORK_ERROR, "Expected General Network Error if the mock is not handled.")
                }
            case .success:
                XCTFail("Expected SSL Pinning failure, but the request succeeded")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Successful API Request (Callback Version)
    func testMakeAPIRequestCallback_Success() {
        let mockResponseData = """
        {
            "message": "Success",
            "data": { "id": 1, "name": "Test" }
        }
        """.data(using: .utf8)!
        MockURLProtocol.stubResponseData = mockResponseData
        MockURLProtocol.stubResponseStatusCode = 200
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.makeAPIRequest(
            url: "https://example.com/api/test",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data.name, "Test")
                XCTAssertEqual(response.data.id, 1)
            case .failure:
                XCTFail("Expected success, but the request failed")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - 404 Not Found (Callback Version)
    func testMakeAPIRequestCallback_NotFound() {
        MockURLProtocol.stubResponseStatusCode = 404
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.makeAPIRequest(
            url: "https://example.com/api/test",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .NETWORK_RESOURCE_NOT_FOUND)
            case .success:
                XCTFail("Expected 404 Not Found error, but the request succeeded")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Forbidden API Request (403)
    func testMakeAPIRequestCallback_Forbidden() {
        MockURLProtocol.stubResponseStatusCode = 403
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.makeAPIRequest(
            url: "https://example.com/api/test",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .UNAUTHENTICATED)
            case .success:
                XCTFail("Expected 403 Forbidden error, but the request succeeded")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - File Upload Callback Test
    func testMakeUploadAPIRequestCallback_Success() {
        let mockResponseData = """
        {
            "message": "File uploaded",
            "data": { "id": 2, "name": "UploadTest" }
        }
        """.data(using: .utf8)!
        MockURLProtocol.stubResponseData = mockResponseData
        MockURLProtocol.stubResponseStatusCode = 200
        
        let mockFileData = UploadableData(
            fileData: Data(),
            fileDataParamName: "file",
            fileName: "test.jpg",
            mimeType: "image/jpeg"
        )
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.makeUploadAPIRequest(
            url: "https://example.com/api/upload",
            parameters: nil,
            fileData: [mockFileData],
            method: .post,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.data.name, "UploadTest")
            case .failure:
                XCTFail("Expected success, but the request failed")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    func testMakeUploadAPIRequest_NoFileData() {
        // Given
        let mockFileData: [UploadableData]? = nil  // No file data provided
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.makeUploadAPIRequest(
            url: "https://example.com/api/upload",
            parameters: nil,
            fileData: mockFileData,
            method: .post,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .UNHANDLED_ERROR(reason: "No file data provided"))
            case .success:
                XCTFail("Expected failure, but got success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMakeAPIRequest_NoInternet() {
        // Simulate no internet connection using MockURLProtocol
        MockURLProtocol.simulateNoInternet = true
        
        let expectation = self.expectation(description: "Completion should be called")
        
        // Please Note:
        // In real scenarios, `NetworkReachability.shared.isNotReachable` will only be `true` if the device is actually offline.
        // To bypass the need for the device to be offline not working you must need keep app offline to test this
        
        networkHelper.makeAPIRequest(
            url: "https://example.com/api/test",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            // Then
            switch result {
            case .failure(let error):
                if error == .NO_INTERNET_CONNECTION {
                    XCTAssertEqual(error, .NO_INTERNET_CONNECTION, "Expected NO_INTERNET_CONNECTION error.")
                }
                // Fallback to .GENERAL_NETWORK_ERROR if the mock setup fails to simulate correctly
                else {
                    XCTAssertEqual(error, .GENERAL_NETWORK_ERROR, "Expected General Network Error if the mock is not handled.")
                }
            case .success:
                XCTFail("Expected failure due to no internet, but got success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        // Reset the MockURLProtocol state after the test
        MockURLProtocol.reset()
    }
    
    func testHandleNewResponse_401Unauthorized() {
        MockURLProtocol.stubResponseStatusCode = 401  // Simulate unauthorized response
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.makeAPIRequest(
            url: "https://example.com/api/test",
            parameters: nil,
            method: .get,
            headers: NetworkHeaders()
        ) { (result: Result<TestModel, NetworkError>, _) in
            // Then
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .UNAUTHENTICATED)
            case .success:
                XCTFail("Expected failure for 401 Unauthorized, but got success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: - NetworkHelper Helper Methods Tests
extension NetworkHelperTests {
    // MARK: - Test: Add Authorization Header If Missing
    
    func testAddAuthorizationIfMissing_MissingAuthorization() {
        // Simulate storing a valid token in UserDefaults
        UserDefaults.standard.set("validToken", forKey: "server_token_new")
        
        let headers = NetworkHeaders(["Authorization": "Bearer "])  // Missing token after "Bearer"
        let finalHeaders = networkHelper.addAuthorizationIfMissing(headers)
        
        // Check if the Authorization header has been correctly updated with the stored token
        XCTAssertNotNil(finalHeaders?.value(for: "Authorization"), "Authorization header should not be nil")
        XCTAssertEqual(finalHeaders?.value(for: "Authorization"), "Bearer validToken", "Expected 'Bearer validToken'")
    }
    
    func testAddAuthorizationIfMissing_NoToken() {
        // Remove token from UserDefaults
        UserDefaults.standard.removeObject(forKey: "server_token_new")
        
        let headers = NetworkHeaders(["Authorization": "Bearer "])  // Missing token after "Bearer"
        let finalHeaders = networkHelper.addAuthorizationIfMissing(headers)
        
        // Check if the Authorization header remains unchanged as no valid token is found
        XCTAssertEqual(finalHeaders?.value(for: "Authorization"), "Bearer ", "Expected 'Bearer ' with no token")
    }
    
    func testAddAuthorizationIfMissing_ValidAuthorization() {
        let headers = NetworkHeaders(["Authorization": "Bearer validTokenAlready"])
        let finalHeaders = networkHelper.addAuthorizationIfMissing(headers)
        
        // The Authorization header should not change as it already contains a valid token
        XCTAssertEqual(finalHeaders?.value(for: "Authorization"), "Bearer validTokenAlready", "Authorization header should remain unchanged")
    }
}
//
// MARK: - Tests for handleDecodedError and decodeError
extension NetworkHelperTests {

    // MARK: - Test: Decoding Dictionary Error in handleDecodedError
    func testHandleDecodedError_WithDictionaryError() {
        // Given: Valid error in dictionary form
        let errorData = """
        {
            "errors": { "code": 400, "message": "Invalid request" }
        }
        """.data(using: .utf8)!
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.handleDecodedError(
            from: errorData,
            statusCode: 400,
            afError: AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        ) { (result: Result<TestModel, NetworkError>, _) in
            // Then: Verify failure due to dictionary error
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .UNHANDLED_ERROR(reason: "Invalid request"))
            case .success:
                XCTFail("Expected failure due to dictionary error, but got success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Test: Decoding Array Error in handleDecodedError
    func testHandleDecodedError_WithArrayError() {
        // Given: Valid error in array form
        let errorData = """
        {
            "errors": [
                { "code": "1001", "message": "Array Error Occurred" }
            ]
        }
        """.data(using: .utf8)!
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.handleDecodedError(
            from: errorData,
            statusCode: 400,
            afError: AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        ) { (result: Result<TestModel, NetworkError>, _) in
            // Then: Verify failure due to array error
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .UNHANDLED_ERROR(reason: "Array Error Occurred"))
            case .success:
                XCTFail("Expected failure due to array error, but got success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Test: handleDecodedError with nil error data
    func testHandleDecodedError_WithNilErrorData() {
        // Given: Nil data
        let nilData: Data? = nil
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.handleDecodedError(
            from: nilData,
            statusCode: 400,
            afError: AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        ) { (result: Result<TestModel, NetworkError>, _) in
            // Then: Verify failure due to nil error data
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .UNHANDLED_ERROR(reason: "We encountered an issue processing the server\'s response. Please try again."))
            case .success:
                XCTFail("Expected failure due to nil error data, but got success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Test: handleDecodedError with AFError fallback
    func testHandleDecodedError_WithAFErrorFallback() {
        // Given: Invalid data (should trigger fallback to AFError)
        let invalidData = """
        {
            "invalid": "data"
        }
        """.data(using: .utf8)!
        
        let expectation = self.expectation(description: "Completion should be called")
        
        networkHelper.handleDecodedError(
            from: invalidData,
            statusCode: 400,
            afError: AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        ) { (result: Result<TestModel, NetworkError>, _) in
            // Then: Verify failure due to AFError fallback
            switch result {
            case .failure(let error):
                XCTAssertEqual(error, .UNHANDLED_ERROR(reason: "oops_text"))
            case .success:
                XCTFail("Expected failure due to AFError fallback, but got success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Test: decodeError with valid dictionary error
    func testDecodeError_ValidDictionaryData() {
        // Given: Valid dictionary error data
        let errorData = """
        {
            "errors": { "code": 400, "message": "Invalid request" }
        }
        """.data(using: .utf8)!
        
        let result = networkHelper.decodeError(value: errorData)
        
        // Then: Verify that it decodes correctly
        XCTAssertNotNil(result)
        if case .dictionary(let errorV2) = result?.errors {
            XCTAssertEqual(errorV2.message, "Invalid request")
            XCTAssertEqual(errorV2.code, 400)
        } else {
            XCTFail("Expected dictionary error type")
        }
    }

    // MARK: - Test: decodeError with valid array error
    func testDecodeError_ValidArrayData() {
        // Given: Valid array error data
        let errorData = """
        {
            "errors": [
                { "code": "1001", "message": "Array Error Occurred" }
            ]
        }
        """.data(using: .utf8)!
        
        let result = networkHelper.decodeError(value: errorData)
        
        // Then: Verify that it decodes correctly
        XCTAssertNotNil(result)
        if case .array(let errorV3Array) = result?.errors {
            XCTAssertEqual(errorV3Array.first?.message, "Array Error Occurred")
            XCTAssertEqual(errorV3Array.first?.code, "1001")
        } else {
            XCTFail("Expected array error type")
        }
    }

    // MARK: - Test: decodeError with nil data
    func testDecodeError_NilData() {
        // Given: Nil data
        let nilData: Data? = nil
        
        let result = networkHelper.decodeError(value: nilData)
        
        // Then: Verify that result is nil
        XCTAssertNil(result, "Result should be nil for nil data")
    }

    // MARK: - Test: decodeError with corrupted JSON
    func testDecodeError_CorruptedJSON() {
        // Given: Corrupted JSON data
        let corruptedJSON = """
        {
            "errors": { "invalid": "data"
        """.data(using: .utf8)!  // Incomplete/corrupted JSON
        
        let result = networkHelper.decodeError(value: corruptedJSON)
        
        // Then: Verify that result is nil
        XCTAssertNil(result, "Result should be nil for corrupted JSON data")
    }

    // MARK: - Test: decodeError with non-JSON data
    func testDecodeError_NonJSONData() {
        // Given: Non-JSON plain text data
        let plainTextData = "This is not JSON".data(using: .utf8)!
        
        let result = networkHelper.decodeError(value: plainTextData)
        
        // Then: Verify that result is nil
        XCTAssertNil(result, "Result should be nil for plain text data")
    }
}
