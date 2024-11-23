//
//  NetworkLogger.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//
/// Enum representing different types of logs.

import Foundation
import LoggerModule

// MARK: - NetworkLogger
final class NetworkLogger {

    static let shared = NetworkLogger()
    
    private init() {}


    /// Logs network requests including URL, headers, and body.
    func logRequest(
            url: String,
            method: String,
            headers: [String: String]?,
            body: [String: Any]?,
            config: LoggerConfig
        ) {
            var logMessage = "[📡 REQUEST] \(method) \(url)\n"
            
            if config.logRequestHeaders, let headers = headers {
                logMessage += "Headers: \(Logger.shared.prettyPrintJSON(headers))\n"
            }
            
            if config.logRequestBody, let body = body {
                logMessage += "Body: \(Logger.shared.prettyPrintJSON(body))\n"
            }
            
            Logger.shared.log(logMessage)
        }
    
    /// Logs network responses including URL, status code, headers, and body.
    func logResponse(
            url: String,
            statusCode: Int?,
            headers: [String: String]?,
            response: Any?,
            config: LoggerConfig
        ) {
            var logMessage = "[📶 RESPONSE] \(url)\n"
            
            if config.logStatusCode, let statusCode = statusCode {
                logMessage += "Status Code: \(statusCode)\n"
            }
            
            if config.logResponseHeaders, let headers = headers {
                logMessage += "Headers: \(Logger.shared.prettyPrintJSON(headers))\n"
            }
            
            if config.logResponseBody, let response = response {
                logMessage += "Response Body: \(Logger.shared.prettyPrintJSON(response))\n"
            }
            
            Logger.shared.log(logMessage)
        }


    /// Logs errors including URL and error details.
    func logError(url: String, error: Error) {
        let logMessage = "[🚨 ERROR] \(url)\nError: \(error.localizedDescription)"
        Logger.shared.log(logMessage)
    }
}
