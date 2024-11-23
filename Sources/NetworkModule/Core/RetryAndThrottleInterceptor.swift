//
//  RetryAndThrottleInterceptor.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-15.
//

import Foundation
import Alamofire

//// MARK: - Retry and Throttle Interceptor
public class RetryAndThrottleInterceptor: RequestInterceptor {
    private let retryLimit: Int
    private let exponentialBackoffBase: Double
    private let exponentialBackoffScale: TimeInterval
    private let throttleInterval: TimeInterval
    
    public init(retryLimit: Int, exponentialBackoffBase: Double, exponentialBackoffScale: TimeInterval, throttleInterval: TimeInterval) {
        self.retryLimit = retryLimit
        self.exponentialBackoffBase = exponentialBackoffBase
        self.exponentialBackoffScale = exponentialBackoffScale
        self.throttleInterval = throttleInterval
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let retryCount = request.retryCount
        guard retryCount < retryLimit else {
            return completion(.doNotRetry)
        }
        
        let backoffDelay = pow(exponentialBackoffBase, Double(retryCount)) * exponentialBackoffScale
        completion(.retryWithDelay(backoffDelay))
    }
}



