//
//  NetworkError.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//

public enum NetworkError: Error, Equatable {
    case FORBIDDEN
    case BAD_TOKEN
    case NO_INTERNET_CONNECTION
    case TIMEOUT
    case NETWORK_RESOURCE_NOT_FOUND
    case SERVER_DOWN_FOR_MAINTENANCE
    case SERVER_OUTAGE
    case DATA_PARSE_ERROR
    case BACKEND_ERROR
    case GENERAL_NETWORK_ERROR
    case CLIENT_SIDE_ERROR
    case SERVER_SIDE_ERROR
    case SSL_PINNING_FAILED
    case UNHANDLED_ERROR(reason: String)
    case API_ERROR(code: Int, message: String)
    case THROTTLED_ERROR(message: String)
    case UNAUTHENTICATED

    public var description: String {
        switch self {
        case .FORBIDDEN: return "Your session has expired. Please log in again."
        case .BAD_TOKEN: return "Invalid session token. Please log in again."
        case .NO_INTERNET_CONNECTION: return "No Internet Connection! Please check your network settings."
        case .TIMEOUT: return "The request timed out. Please try again."
        case .NETWORK_RESOURCE_NOT_FOUND: return "The requested resource could not be found."
        case .SERVER_DOWN_FOR_MAINTENANCE: return "The server is currently down for maintenance."
        case .SERVER_OUTAGE: return "The server is experiencing an outage."
        case .DATA_PARSE_ERROR: return "Failed to parse the response data."
        case .BACKEND_ERROR: return "An error occurred on the server side."
        case .GENERAL_NETWORK_ERROR: return "A network error occurred. Please check your internet connection."
        case .CLIENT_SIDE_ERROR: return "An error occurred on the client side."
        case .SERVER_SIDE_ERROR: return "An error occurred on the server side."
        case .SSL_PINNING_FAILED: return "SSL Pinning failed. Please contact support."
        case .UNHANDLED_ERROR(let reason): return "Unhandled error: \(reason)"
        case .API_ERROR(let code, let message): return "API error (Code: \(code)): \(message)"
        case .THROTTLED_ERROR(let message): return "Error: \(message)"
        case .UNAUTHENTICATED: return "Your session has expired. Please log in."
        }
    }
}
