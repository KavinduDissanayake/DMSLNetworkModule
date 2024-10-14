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
            return .UNHANDLED_ERROR(reason: "Something went wrong while preparing the upload. Please try again.")
        
        case .createURLRequestFailed:
            return .UNHANDLED_ERROR(reason: "There was an issue creating the request. Please try again later.")
        
        case .downloadedFileMoveFailed:
            return .UNHANDLED_ERROR(reason: "The file couldn't be saved. Please check your device's storage and try again.")
        
        case .explicitlyCancelled:
            return .UNHANDLED_ERROR(reason: "The request was cancelled. Please try again if needed.")
        
        case .invalidURL:
            return .UNHANDLED_ERROR(reason: "The server URL is incorrect. Please contact support.")
        
        case .multipartEncodingFailed:
            return .UNHANDLED_ERROR(reason: "There was an issue processing your data. Please try again.")
        
        case .parameterEncodingFailed:
            return .UNHANDLED_ERROR(reason: "Failed to process the request. Please check your input and try again.")
        
        case .parameterEncoderFailed:
            return .UNHANDLED_ERROR(reason: "There was an issue sending your request. Please try again later.")
        
        case .requestAdaptationFailed:
            return .UNHANDLED_ERROR(reason: "There was an issue adjusting your request. Please contact support.")
        
        case .requestRetryFailed:
            return .UNHANDLED_ERROR(reason: "We couldn't complete the request after multiple attempts. Please check your connection and try again.")
        
        case .responseValidationFailed:
            return .DATA_PARSE_ERROR // Use a simple message for this in the higher level switch-case

        case .responseSerializationFailed:
            return .UNHANDLED_ERROR(reason: "We encountered an issue processing the server's response. Please try again.")
        
        case .serverTrustEvaluationFailed:
            return .SSL_PINNING_FAILED // Can be handled as a custom scenario elsewhere
        
        case .urlRequestValidationFailed:
            return .UNHANDLED_ERROR(reason: "There was an issue validating the request. Please try again.")
        
        default:
            return .GENERAL_NETWORK_ERROR // Catch-all for any other unknown errors
        }
    }
}
