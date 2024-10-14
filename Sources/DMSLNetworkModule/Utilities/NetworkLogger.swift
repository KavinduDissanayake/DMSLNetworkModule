//
//  NetworkLogger.swift
//  DMSLNetworkModule
//
//  Created by Kavindu Dissanayake on 2024-10-12.
//
/// Enum representing different types of logs.

import Foundation

// MARK: - NetworkLogger
final class NetworkLogger {

    static let shared = NetworkLogger()
    
    private init() {}

    /// Logs a formatted message with optional file, function, and line details.
    func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let shortFileName = file.components(separatedBy: "/").last ?? "---"
        let header = "\(shortFileName) - \(function) - line \(line)"
        let formattedMessage = "\n\(message)\n\(String(repeating: "-", count: header.count))\n"
        print(formattedMessage)
    }
    
    /// Pretty-prints a JSON object if valid, otherwise returns a string representation.
    func prettyPrintJSON(_ json: Any) -> String {
        guard JSONSerialization.isValidJSONObject(json) else {
            return "\(json)"  // Return raw value if it's not a valid JSON object
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            return String(data: data, encoding: .utf8) ?? "\(json)"
        } catch {
            return "Invalid JSON"
        }
    }

    /// Logs network requests including URL, headers, and body.
    func logRequest(url: String, method: String, headers: [String: String]?, body: [String: Any]?) {
        var logMessage = "[📡 REQUEST] \(method) \(url)\n"
        
        if let headers = headers {
            logMessage += "Headers: \(prettyPrintJSON(headers))\n"
        }
        
        if let body = body {
            logMessage += "Body: \(prettyPrintJSON(body))\n"
        }
        
        log(logMessage)
    }

    /// Logs network responses including URL, status code, headers, and body.
    func logResponse(url: String, statusCode: Int?, headers: [String: String]?, response: Any?) {
        var logMessage = "[📶 RESPONSE] \(url)\n"
        
        if let statusCode = statusCode {
            logMessage += "Status Code: \(statusCode)\n"
        }
        
        if let headers = headers {
            logMessage += "Headers: \(prettyPrintJSON(headers))\n"
        }
        
        if let response = response {
            logMessage += "Response Body: \(prettyPrintJSON(response))\n"
        }
        
        log(logMessage)
    }

    /// Logs errors including URL and error details.
    func logError(url: String, error: Error) {
        let logMessage = "[🚨 ERROR] \(url)\nError: \(error.localizedDescription)"
        log(logMessage)
    }
}
