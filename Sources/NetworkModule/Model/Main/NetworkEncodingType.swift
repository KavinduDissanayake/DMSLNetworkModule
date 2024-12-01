//
//  NetworkEncodingType.swift
//  DMSLSwiftPackages
//
//  Created by KavinduDissanayake on 2024-12-01.
//
import Alamofire
import Foundation
/// Enum defining types of parameter encoding for network requests.
public enum NetworkEncodingType {
    case urlEncoded
    case jsonEncoded

    /// Returns the appropriate `ParameterEncoding` instance for the selected type.
    public var encoding: ParameterEncoding {
        switch self {
        case .urlEncoded: return URLEncoding.default
        case .jsonEncoded: return JSONEncoding.default
        }
    }
}
