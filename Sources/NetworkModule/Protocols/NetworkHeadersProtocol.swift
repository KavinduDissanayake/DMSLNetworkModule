//
//  NetworkHeadersProtocol.swift
//  DMSLSwiftPackages
//
//  Created by KavinduDissanayake on 2024-12-01.
//

/// Protocol defining the responsibilities of a network headers type.
public protocol NetworkHeadersProtocol: Equatable, Hashable, Sendable {
    /// Adds or updates a header value.
    mutating func add(_ value: String, for key: String)

    /// Retrieves a header value for the specified key.
    func value(for key: String) -> String?

    /// Returns all headers as a dictionary.
    func allHeaders() -> [String: String]
}
