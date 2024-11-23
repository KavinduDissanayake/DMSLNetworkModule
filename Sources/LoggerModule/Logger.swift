//
//  LoggerModule.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-21.
//

import Foundation

// MARK: - Logger
final public class Logger {

    public static let shared = Logger()

    private init() {}
    /// Logs a formatted message with optional file, function, and line details.
    public func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let shortFileName = file.components(separatedBy: "/").last ?? "---"
        let header = "\(shortFileName) - \(function) - line \(line)"
        let formattedMessage = "\n\(message)\n\(String(repeating: "-", count: header.count))\n"
        print(formattedMessage)
    }
    
    /// Pretty-prints a JSON object if valid, otherwise returns a string representation.
    public func prettyPrintJSON(_ json: Any) -> String {
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
}
