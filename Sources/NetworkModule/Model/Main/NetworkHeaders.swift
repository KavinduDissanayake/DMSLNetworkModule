//
//  NetworkHeaders.swift
//  DMSLSwiftPackages
//
//  Created by KavinduDissanayake on 2024-12-01.
//
import Alamofire

/// A type representing HTTP headers for network requests.
public struct NetworkHeaders: NetworkHeadersProtocol {
    private var headers: [String: String]

    public init(_ headers: [String: String] = [:]) {
        self.headers = headers
    }

    public mutating func add(_ value: String, for key: String) {
        headers[key] = value
    }

    public func value(for key: String) -> String? {
        return headers[key]
    }

    public func allHeaders() -> [String: String] {
        return headers
    }
}
extension NetworkHeaders {
    /// Converts `NetworkHeaders` to Alamofire's `HTTPHeaders`.
    public func toHTTPHeaders() -> HTTPHeaders {
        return HTTPHeaders(self.allHeaders())
    }
}
