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
      .listStyle(.insetGrouped)
      .environment(\.defaultMinListRowHeight, 44)
    }
  }

  private var cellBackground: Color {
    Color.white.opacity(0.08)
  }

  private func sectionHeader(_ title: String) -> some View {
    Text(title)
      .foregroundStyle(Color.white.opacity(0.7))
      .font(.footnote)
  }

  // MARK: - Language
  private var languageSection: some View {
    Section(header: sectionHeader(String.settingsLanguage)) {
      Button {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      } label: {
        HStack {
          Text(String.settingsChangeLanguage)
            .foregroundStyle(.white)
          Spacer()
          Text(AppLanguage.current.displayName)
            .foregroundStyle(Color.white.opacity(0.5))
          Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(Color.white.opacity(0.5))
        }
      }
      .listRowBackground(cellBackground)
      .listRowSeparatorTint(Color.white.opacity(0.15))
    }
  }

  // MARK: - SF Symbols
  private var sfSymbolsSection: some View {
    Section(header: sectionHeader(String.settingsSFSymbolsSupportedVersions)) {
      versionRow(feature: String.settingsSFSymbolsVersionDraw, version: "SF Symbols 5.1 / iOS 16+")
      versionRow(feature: String.settingsSFSymbolsVersionBrowse, version: "SF Symbols 7.2 / iOS 16+")
      versionRow(feature: String.settingsSFSymbolsVersionSearch, version: "SF Symbols 7.2 / iOS 26+")
    }
  }

  private func versionRow(feature: String, version: String) -> some View {
    HStack {
      Text(feature)
        .foregroundStyle(.white)
      Spacer()
      Text(version)
        .foregroundStyle(Color.white.opacity(0.5))
    }
    .listRowBackground(cellBackground)
    .listRowSeparatorTint(Color.white.opacity(0.15))
  }

  // MARK: - App Info
  private var appInfoSection: some View {
    Section(header: sectionHeader(String.settingsAppInfo)) {
      HStack {
        Text(String.settingsCurrentVersion)
          .foregroundStyle(.white)
        Spacer()
        Text(Bundle.main.appVersion)
          .foregroundStyle(Color.white.opacity(0.5))
      }
      .listRowBackground(cellBackground)
      .listRowSeparatorTint(Color.white.opacity(0.15))
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
