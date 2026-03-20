//
//  SettingsView.swift
//  SF-Symbol-Finder
//
//  Created by ZENA on 2026/03/09.
//

import SwiftUI

struct SettingsView: View {

  var body: some View {
    ZStack {
      Color.neutral.ignoresSafeArea()
      List {
        languageSection
        sfSymbolsSection
        appInfoSection
      }
      .scrollContentBackground(.hidden)
    }
  }

  // MARK: - Language
  private var languageSection: some View {
    Section(header: Text(String.settingsLanguage)) {
      Button {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      } label: {
        HStack {
          Text(String.settingsChangeLanguage)
            .foregroundStyle(.primary)
          Spacer()
          Text(AppLanguage.current.displayName)
            .foregroundStyle(.secondary)
          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
  }

  // MARK: - SF Symbols
  private var sfSymbolsSection: some View {
    Section(header: Text(String.settingsSFSymbolsSupportedVersions)) {
      versionRow(feature: String.settingsSFSymbolsVersionDraw, version: "SF Symbols 5.1")
      versionRow(feature: String.settingsSFSymbolsVersionBrowse, version: "SF Symbols 7.2")
      versionRow(feature: String.settingsSFSymbolsVersionSearch, version: "SF Symbols 7.2")
    }
  }

  private func versionRow(feature: String, version: String) -> some View {
    HStack {
      Text(feature)
      Spacer()
      Text(version)
        .foregroundStyle(.secondary)
    }
  }

  // MARK: - App Info
  private var appInfoSection: some View {
    Section(header: Text(String.settingsAppInfo)) {
      HStack {
        Text(String.settingsCurrentVersion)
        Spacer()
        Text(Bundle.main.appVersion)
          .foregroundStyle(.secondary)
      }
    }
  }
}

// MARK: - Bundle Extension
extension Bundle {
  var appVersion: String {
    infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
  }
}

// MARK: - App Language
enum AppLanguage: String, CaseIterable {
  case korean = "ko"
  case english = "en"

  var displayName: String {
    switch self {
    case .korean: return "한국어"
    case .english: return "English"
    }
  }

  static var current: AppLanguage {
    let preferred = Locale.preferredLanguages.first ?? "en"
    if preferred.hasPrefix("ko") {
      return .korean
    }
    return .english
  }
}
