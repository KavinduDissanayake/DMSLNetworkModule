//
//  NetworkHelperHttpMethod.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-11.
//

import Foundation
import Alamofire

public enum NetworkHttpMethod {
    /// `CONNECT` method.
    case connect
    /// `DELETE` method.
    case delete
    /// `GET` method.
    case get
    /// `HEAD` method.
    case head
    /// `OPTIONS` method.
    case options
    /// `PATCH` method.
    case patch
    /// `POST` method.
    case post
    /// `PUT` method.
    case put
    /// `QUERY` method.
    case query
    /// `TRACE` method.
    case trace
}

extension NetworkHttpMethod{
    public var method: HTTPMethod {
        let httpMethod: HTTPMethod
        switch self {
        case .connect:
            httpMethod = HTTPMethod.connect
        case .delete:
            httpMethod = HTTPMethod.delete
        case .get:
            httpMethod = HTTPMethod.get
        case .head:
            httpMethod = HTTPMethod.head
        case .options:
            httpMethod = HTTPMethod.options
        case .patch:
            httpMethod = HTTPMethod.patch
        case .post:
            httpMethod = HTTPMethod.post
        case .put:
            httpMethod = HTTPMethod.put
        case .query:
            httpMethod = HTTPMethod.query
        case .trace:
            httpMethod = HTTPMethod.trace
        }
        return httpMethod
    }
}
