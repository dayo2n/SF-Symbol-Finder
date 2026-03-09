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
  case describe
  case settings

  var title: String {
    switch self {
    case .draw: return String.searchModeDraw
    case .browse: return String.searchModeBrowse
    case .describe: return String.searchModeDescribe
    case .settings: return String.settings
    }
  }
}
