//
//  SearchMode.swift
//  SF-Symbol-Finder
//
//  Created by ZENA on 3/6/26.
//

import Foundation

enum SearchMode: String, CaseIterable {
  case browse
  case draw
  case search
  case settings

  var title: String {
    switch self {
    case .draw: return String.searchModeDraw
    case .browse: return String.searchModeBrowse
    case .search: return String.searchModeSearch
    case .settings: return String.settings
    }
  }
}
