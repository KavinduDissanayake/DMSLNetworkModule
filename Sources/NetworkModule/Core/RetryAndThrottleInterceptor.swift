//
//  RetryAndThrottleInterceptor.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-15.
//

import Foundation
import Alamofire

/// Siwft 6 can be crased - fixed
/// 1. Ensure RetryAndThrottleInterceptor explicitly conforms to @unchecked Sendable if you are confident that your manual synchronization will ensure thread safety.
/// 2. Use a thread-safe mechanism to handle access to lastRequestTimes.

/// A request interceptor that throttles network requests and ensures thread-safe access to the tracking dictionary.
/// It uses a `DispatchQueue` for thread safety and provides manual synchronization.
/// This class is marked as `@unchecked Sendable` because manual synchronization is used to guarantee thread safety.
///
/// **Key Features:**
/// - Prevents rapid repeated requests to the same endpoint within a specified throttle interval.
/// - Ensures thread-safe reads and writes to the `lastRequestTimes` dictionary using a concurrent dispatch queue.
public class RetryAndThrottleInterceptor: NetworkRequestInterceptor, @unchecked Sendable {
    
    /// The minimum time interval between repeated requests to the same endpoint.
    private let throttleInterval: TimeInterval

    /// A dictionary to track the timestamp of the last request for each unique endpoint.
    /// Keys are generated based on the URL, HTTP method, and body content.
    /// This dictionary is accessed and modified in a thread-safe manner using a `DispatchQueue`.
    private var lastRequestTimes: [String: Date] = [:]
    
    /// A concurrent dispatch queue used for synchronizing access to `lastRequestTimes`.
    /// - Concurrent reads improve performance.
    /// - Writes are serialized using a barrier to ensure data consistency.
    private let queue = DispatchQueue(label: "RetryAndThrottleInterceptor.queue", attributes: .concurrent)

    /// Initializes the interceptor with a specified throttle interval.
    /// - Parameter throttleInterval: The minimum time interval (in seconds) between repeated requests to the same endpoint. Default is 0.005 seconds.
    public init(throttleInterval: TimeInterval = 0.005) {
        self.throttleInterval = throttleInterval
    }

    /// Intercepts and adapts a network request before it is executed.
    /// This method checks if the request is within the throttle interval and decides whether to allow or block it.
    ///
    /// - Parameters:
    ///   - urlRequest: The original URL request.
    ///   - session: The Alamofire session handling the request.
    ///   - completion: A closure to execute with the adapted request or an error.
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let currentTime = Date()
        let requestKey = generateRequestKey(for: urlRequest)

        // Perform a thread-safe read to check the last request time for this endpoint.
        queue.sync {
            if let lastRequestTime = lastRequestTimes[requestKey],
               currentTime.timeIntervalSince(lastRequestTime) < throttleInterval {
                // If the request is within the throttle interval, block it and return an error.
                completion(.failure(NetworkError.THROTTLED_ERROR(message: "Request throttled")))
                return
            }
        }

        // Perform a thread-safe write to update the last request time for this endpoint.
        queue.async(flags: .barrier) {
            self.lastRequestTimes[requestKey] = currentTime
            // Allow the request to proceed.
            completion(.success(urlRequest))
        }
    }

    /// Generates a unique key for the request based on its URL, HTTP method, and body content.
    /// - Parameter request: The URL request for which to generate the key.
    /// - Returns: A string representing the unique key for the request.
    private func generateRequestKey(for request: URLRequest) -> String {
        let url = request.url?.absoluteString ?? ""
        let method = request.httpMethod ?? ""
        let bodyString = request.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        return "\(method)\(url)\(bodyString)"
    }
}
