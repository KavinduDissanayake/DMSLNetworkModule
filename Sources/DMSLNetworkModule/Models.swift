//
//  Models.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-09.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingError
    case unauthorized
    case unknown(Error)
}

