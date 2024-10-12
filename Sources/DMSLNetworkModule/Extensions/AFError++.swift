//
//  AFError++.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//
import Alamofire

extension AFError {
    /// Converts AFError into NetworkError with user-friendly messages
    func asNetworkError() -> NetworkError {
        switch self {
        case .createUploadableFailed:
            return .UNHANDLED_ERROR(reason: "Failed to create uploadable content. Please try again.")
        case .createURLRequestFailed:
            return .UNHANDLED_ERROR(reason: "There was a problem creating the request. Please try again.")
        case .downloadedFileMoveFailed:
            return .UNHANDLED_ERROR(reason: "Failed to move the downloaded file. Please check available storage.")
        case .explicitlyCancelled:
            return .UNHANDLED_ERROR(reason: "The request was cancelled.")
        case .invalidURL:
            return .UNHANDLED_ERROR(reason: "The URL provided is invalid. Please contact support.")
        case .multipartEncodingFailed:
            return .UNHANDLED_ERROR(reason: "There was an issue encoding the file. Please try again.")
        case .parameterEncodingFailed:
            return .UNHANDLED_ERROR(reason: "Failed to encode the request parameters. Please try again.")
        case .parameterEncoderFailed:
            return .UNHANDLED_ERROR(reason: "There was an issue with the request parameters. Please try again.")
        case .requestAdaptationFailed:
            return .UNHANDLED_ERROR(reason: "Failed to adapt the request. Please contact support.")
        case .requestRetryFailed:
            return .UNHANDLED_ERROR(reason: "Retrying the request failed. Please check your connection and try again.")
        case .responseValidationFailed:
            return .DATA_PARSE_ERROR // Typically when the server's response is invalid or cannot be parsed
        case .responseSerializationFailed:
            return .UNHANDLED_ERROR(reason: "Failed to process the server response. Please try again.")
        case .serverTrustEvaluationFailed:
            return .SSL_PINNING_FAILED // Specifically for SSL Pinning failure
        case .urlRequestValidationFailed:
            return .UNHANDLED_ERROR(reason: "The request validation failed. Please try again.")
        default:
            return .GENERAL_NETWORK_ERROR // Catch-all for any unknown errors
        }
    }
}
