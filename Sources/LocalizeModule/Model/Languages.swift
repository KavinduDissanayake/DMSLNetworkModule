//
//  Languages.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-16.
//
import Foundation
import Lokalise

public enum Languages: String, Codable,CaseIterable {
    case SINHALA = "සිංහල"
    case TAMIL = "தமிழ்"
    case ENGLISH = "English"
    case NEPALI = "नेपाली"
    
    // Dictionary mapping languages to their codes
    private static let languageCodeMap: [Self: String] = [
        .SINHALA: "si",
        .TAMIL: "ta",
        .ENGLISH: "en",
        .NEPALI: "ne"
    ]
    
    public var languageCode: String {
        return Self.languageCodeMap[self] ?? "en"  // Default to English if not found
    }
    
    // Reverse dictionary to find the language from the code
    private static let codeToLanguageMap = Dictionary(uniqueKeysWithValues: languageCodeMap.map { ($1, $0) })
    
    static func languageFromCode(_ code: String) -> Self? {
        return codeToLanguageMap[code]
    }
}

extension Languages {
    public static var current: Languages {
        return Languages(rawValue: Lokalise.shared.localizationLocale.identifier) ?? .ENGLISH
    }
}
