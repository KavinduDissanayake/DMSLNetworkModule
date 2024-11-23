//
//  LocalizationService.swift
//  DMSLSwiftPackages
//
//  Created by Kavindu Dissanayake on 2024-10-16.
//

import Foundation
import SwiftUI
import Lokalise

public class LocalizationService: ObservableObject {
    
    public static let shared = LocalizationService()
    
    @AppStorage("languageCode") private var storedLanguageCode: String = LocalizationConfiguration.shared.defaultLanguage.languageCode
    
    @Published public var currentLanguage: Languages = LocalizationConfiguration.shared.defaultLanguage {
        didSet {
            if oldValue != currentLanguage {
                logServiceEvent("🔄 Language changed to: \(currentLanguage.rawValue)")
                updateLocalization(language: currentLanguage)
            }
        }
    }
    
    @Published public var lokaliseUpdate = false
    private var isUpdatingFromApp = false
    
    private init() {
        configureLokalise()
        let savedLanguageCode = storedLanguageCode
        currentLanguage = Languages.languageFromCode(savedLanguageCode) ?? .ENGLISH
        updateLocalization(language: currentLanguage)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleLokaliseUpdate), name: NSNotification.Name.LokaliseDidUpdateLocalization, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkForUpdates), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        logServiceEvent("🧹 LocalizationService deinitialized and observers removed.")
    }
    
    /// Configures Lokalise with project ID and token from `LocalizationConfiguration`.
    private func configureLokalise() {
        guard let projectID = LocalizationConfiguration.shared.lokaliseProjectID,
              let token = LocalizationConfiguration.shared.lokaliseToken else {
            logServiceEvent("❗️Lokalise project ID or token is missing in configuration.")
            return
        }
        
        // Set Lokalise project ID and token
        Lokalise.shared.setProjectID(projectID, token: token)
        logServiceEvent("🔑 Lokalise configured with Project ID: \(projectID)")
    }
    
    @objc private func handleLokaliseUpdate() {
        let currentLocale = Lokalise.shared.localizationLocale
        let localeIdentifier = currentLocale.identifier
        logServiceEvent("🌐 LokaliseDidUpdateLocalization: \(localeIdentifier)")
        lokaliseUpdate = true
        
        if isUpdatingFromApp {
            logServiceEvent("⚠️ Skipping update from Lokalise to avoid loop.")
            return
        }
        
        if let newLanguage = Languages.languageFromCode(localeIdentifier), newLanguage != currentLanguage {
            logServiceEvent("🌐 Language updated by Lokalise to: \(newLanguage.rawValue)")
            DispatchQueue.main.async {
                self.currentLanguage = newLanguage
            }
        }
    }
    
    @objc private func checkForUpdates() {
        Lokalise.shared.checkForUpdates { (updated, errorOrNil) in
            if let error = errorOrNil {
                self.logServiceEvent("⚠️ Error checking for updates: \(error.localizedDescription)")
                return
            }
            self.logServiceEvent("🌐 Localization updates checked. Updated: \(updated)")
            if updated {
                self.logServiceEvent("🌐 New localizations available!")
                self.lokaliseUpdate = true
            }
        }
    }
    
    func updateLocalization(language: Languages) {
        let currentLocaleIdentifier = Lokalise.shared.localizationLocale.identifier
        if currentLocaleIdentifier == language.languageCode {
            logServiceEvent("⚠️ Localization already set to: \(language.rawValue). No update needed.")
            return
        }
        
        logServiceEvent("🌐 Updating Lokalise to language: \(language.languageCode)")
        storedLanguageCode = language.languageCode
        isUpdatingFromApp = true
        
        Lokalise.shared.deswizzleMainBundle()
        Lokalise.shared.setLocalizationLocale(Locale(identifier: language.languageCode), makeDefault: false)
        Lokalise.shared.swizzleMainBundle()
        
        isUpdatingFromApp = false
        NotificationCenter.default.post(name: .languageDidChange, object: nil, userInfo: ["language": language])
    }
    
    /// Logs service-related events, respecting `enableServiceLog` flag.
     func logServiceEvent(_ message: String) {
        guard LocalizationConfiguration.shared.enableServiceLog else { return }
        LocalizeLogger.shared.log(message)
    }
}
