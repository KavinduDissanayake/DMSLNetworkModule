//
//  LocalizationConfiguration.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-16.
//

import Foundation

public class LocalizationConfiguration {
    public static let shared = LocalizationConfiguration()
    
    // Project-specific configurations for Lokalise
    public var lokaliseProjectID: String?
    public var lokaliseToken: String?
    
    // Other configurations like default language, logging, etc.
    public var defaultLanguage: Languages = .ENGLISH
    public var isLoggingEnabled: Bool = true  // General logging flag
    
    // New advanced logging controls
    public var enableServiceLog: Bool = true        // Enable service log
    public var enableMissingStringLog: Bool = true  // Enable missing string log
    
    public var localizedFileName: String = "Localizable"

    private init() {}  // Singleton instance
}
