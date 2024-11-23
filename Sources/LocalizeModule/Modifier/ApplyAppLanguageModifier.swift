//
//  ApplyAppLanguageModifier.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-16.
//
import SwiftUI

struct ApplyAppLanguageModifier: ViewModifier {
    @StateObject var localizationService = LocalizationService.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                localizationService.updateLocalization(language: localizationService.currentLanguage)
            }
            .onReceive(NotificationCenter.default.publisher(for: .languageDidChange)) { notification in
                if let newLanguage = notification.userInfo?["language"] as? Languages {
                    LocalizeLogger.shared.log("🌐 Language changed to: \(newLanguage.rawValue)")
                    localizationService.updateLocalization(language: newLanguage)
                }
            }
            .environment(\.locale, Locale(identifier: localizationService.currentLanguage.languageCode))
    }
}

public extension View {
      func applyAppLanguage() -> some View {
        self.modifier(ApplyAppLanguageModifier())
    }
}
