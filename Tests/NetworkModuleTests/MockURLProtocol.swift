//
//  MockURLProtocol.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-13.
//

import Foundation
// MARK: - MockURLProtocol to Simulate Network Conditions
class MockURLProtocol: URLProtocol {
    // Static variables to store stubs
    static var stubResponseData: Data?
    static var stubResponseStatusCode: Int = 200
    static var simulateNoInternet = false
    static var simulateSSLPinningError = false
    static var stubError: Error?
    static var stubResponseHeaders: [String: String]? // Updated for header support

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        // Simulate no internet connection
        if MockURLProtocol.simulateNoInternet {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
        }
        // Simulate SSL pinning error
        else if MockURLProtocol.simulateSSLPinningError {
            let sslError = NSError(domain: NSURLErrorDomain, code: NSURLErrorServerCertificateUntrusted, userInfo: nil)
            client?.urlProtocol(self, didFailWithError: sslError)
        }
        // Simulate custom stub error if set
        else if let error = MockURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
        }
        // Simulate success response with optional stubbed data and headers
        else {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: MockURLProtocol.stubResponseStatusCode,
                httpVersion: nil,
                headerFields: MockURLProtocol.stubResponseHeaders
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = MockURLProtocol.stubResponseData {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
        // No action required
    }

    static func reset() {
        // Reset all static variables
        stubResponseData = nil
        stubResponseStatusCode = 200
        stubResponseHeaders = nil // Reset headers
        simulateNoInternet = false
        simulateSSLPinningError = false
        stubError = nil
    }
}
