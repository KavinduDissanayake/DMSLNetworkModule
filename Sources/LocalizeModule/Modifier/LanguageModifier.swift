//
//  Untitled.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-16.
//
import SwiftUI

// Modifier for Sinhala Language
struct ApplySinhalaLanguageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.environment(\.locale, Locale(identifier: "si"))
            .onAppear{
                LocalizationService.shared.updateLocalization(language: .SINHALA)
            }
    }
}

// Modifier for Tamil Language
struct ApplyTamilLanguageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.environment(\.locale, Locale(identifier: "ta"))
            .onAppear{
                LocalizationService.shared.updateLocalization(language: .TAMIL)
            }
    }
}

// Modifier for English Language
struct ApplyEnglishLanguageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.environment(\.locale, Locale(identifier: "en"))
            .onAppear{
                LocalizationService.shared.updateLocalization(language: .ENGLISH)
            }
    }
}


// Modifier for Sinhala Language
struct ApplyNepalLanguageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.environment(\.locale, Locale(identifier: "ne"))
            .onAppear{
                LocalizationService.shared.updateLocalization(language: .NEPALI)
            }
    }
}


public extension View {
    func applySinhalaLanguage() -> some View {
        self.modifier(ApplySinhalaLanguageModifier())
    }

     func applyTamilLanguage() -> some View {
        self.modifier(ApplyTamilLanguageModifier())
           
    }

    func applyEnglishLanguage() -> some View {
        self.modifier(ApplyEnglishLanguageModifier())
    }
    
     func applyNepalLanguage() -> some View {
        self.modifier(ApplyNepalLanguageModifier())
    }
}
