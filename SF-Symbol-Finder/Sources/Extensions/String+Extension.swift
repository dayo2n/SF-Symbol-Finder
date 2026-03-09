//
//  String+Extension.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/5/24.
//

import Foundation

// MARK: - Localization Methods
extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    func localized(with argument: CVarArg = [], comment: String = "") -> String {
        return String(format: self.localized(comment: comment), argument)
    }
}

// MARK: - Localized Strings
extension String {
    /* App */
    static let app = "SFSymbolFinder".localized()

    /* ContentView */
    static let errorAlert = "errorAlert".localized()
    
    /* CnavasView */
    static let buttonClear = "ButtonClear".localized()
    static let buttonSearch = "ButtonSearch".localized()

    /* ResultView */
    static let waitingForResult = "WaitingForResult".localized()
    static let guideOnUseResultList = "GuideOnUseResultList".localized()
    static let confidence = "confidence".localized()

    /* SFSymbolListView*/
    static let guideOnClickToCopy = "GuideOnClickToCopy".localized()
    static let alertCopied = "AlertCopied".localized()

    /* NaturalLanguageSearchView */
    static let searchModeDraw = "SearchModeDraw".localized()
    static let searchModeBrowse = "SearchModeBrowse".localized()
  static let searchModeSearch = "searchModeSearch".localized()
    static let nlSearchPlaceholder = "NLSearchPlaceholder".localized()
    static let nlSearchGuide = "NLSearchGuide".localized()
    static let nlSearching = "NLSearching".localized()
    static let nlNoResults = "NLNoResults".localized()
    static let nlModelDeviceNotEligible = "NLModelDeviceNotEligible".localized()
    static let nlModelNotEnabled = "NLModelNotEnabled".localized()
    static let nlModelNotReady = "NLModelNotReady".localized()
    static let nlModelError = "NLModelError".localized()

    /* Settings */
    static let settings = "Settings".localized()
    static let settingsLanguage = "SettingsLanguage".localized()
    static let settingsSFSymbols = "SettingsSFSymbols".localized()
    static let settingsSFSymbolsVersion = "SettingsSFSymbolsVersion".localized()
    static let settingsSFSymbolsVersionValue = "SettingsSFSymbolsVersionValue".localized()
    static let settingsSFSymbolsCount = "SettingsSFSymbolsCount".localized()
    static let settingsAppInfo = "SettingsAppInfo".localized()
    static let settingsCurrentVersion = "SettingsCurrentVersion".localized()
    static let settingsChangeLanguage = "SettingsChangeLanguage".localized()

}

// MARK: - SF Symbols
extension String {
    static let chevronBackward = "chevron.backward"
    static let docOnClipboard = "doc.on.clipboard"
    static let arrowUturnBackward = "arrow.uturn.backward"
    static let arrowUturnForward = "arrow.uturn.forward"
    static let exclamationmarkWarninglightFill = "exclamationmark.warninglight.fill"
}
