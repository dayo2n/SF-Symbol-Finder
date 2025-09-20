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

}

// MARK: - SF Symbols
extension String {
    struct SFSymbol {
        static let chevronBackward = "chevron.backward"
        static let docOnClipboard = "doc.on.clipboard"
        static let arrowUturnBackward = "arrow.uturn.backward"
        static let arrowUturnForward = "arrow.uturn.forward"
        static let exclamationmarkWarninglightFill = "exclamationmark.warninglight.fill"
        static let gearshape = "gearshape"
    }
}

// MARK: - Image
extension String {
    struct Image {
        static let imgAppIcon = "img_app_icon"
    }
}
