//
//  LocalizeLogger.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-16.
//
import Foundation
import LoggerModule

// MARK: - LocalizeLogger
final class LocalizeLogger {

    static let shared = LocalizeLogger()

    private init() {}

    /// Logs a message if logging is enabled in the configuration
    func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard LocalizationConfiguration.shared.isLoggingEnabled else { return }
        Logger.shared.log(message, file: file, function: function, line: line)
    }
}
