//
//  Frame6View.swift
//  SFSymbolFinder
//
//  Created by 제나 on 2/5/24.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
  @State var isClear = false
  @State var canvasRepresentingView: CanvasRepresentingView?
  @Environment(\.undoManager) var undoManager
  @State var results = [Result]()
  @State var isNavigate = false
  @State var selectedLabel = ""
  @State var showErrorAlert = false
  @State var onAppeared = false
  @State private var searchMode: SearchMode = .draw
  @State private var isSearchActive = false
  @FocusState private var isSearchFieldFocused: Bool
  @EnvironmentObject var orientation: Orientation
  var defaultPadding: CGFloat {
    Constants.deviceModel == DeviceModel.iPad.rawValue ? 30 : 10
  }
  
  var body: some View {
#if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      tabViewBody
        .onAppear {
          if !onAppeared {
            canvasRepresentingView = CanvasRepresentingView(isClear: $isClear)
            onAppeared = true
          }
        }
    } else if #available(iOS 18.0, *) {
      legacyTabViewBody
    } else {
      legacyBody
    }
#else
    legacyBody
#endif
  }
  
#if canImport(FoundationModels)
  @available(iOS 26.0, *)
  private var tabViewBody: some View {
    DescribeTabWrapper(
      searchMode: $searchMode,
      showErrorAlert: showErrorAlert,
      drawContent: { drawContent },
      errorOverlay: { errorOverlay }
    )
  }

  @available(iOS 18.0, *)
  private var legacyTabViewBody: some View {
    ZStack {
      TabView(selection: $searchMode) {
        Tab(String.searchModeDraw, systemImage: "pencil.and.scribble", value: .draw) {
          drawContent
        }
        Tab(String.searchModeBrowse, systemImage: "square.grid.2x2", value: .browse) {
          ZStack {
            Color.neutral.ignoresSafeArea()
            SFSymbolListView(keyword: "")
          }
        }
        Tab(String.settings, systemImage: "gearshape", value: .settings) {
          SettingsView()
        }
        Tab(String.searchModeDescribe, systemImage: "magnifyingglass", value: .describe) {
          ZStack {
            Color.neutral.ignoresSafeArea()
            VStack(spacing: 16) {
              Image(systemName: "apple.intelligence")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
              Text(String.nlSearchUnavailable)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding()
          }
        }
      }
      .onAppear { configureTabBarAppearance() }

      if showErrorAlert {
        errorOverlay
      }
    }
    .onAppear {
      if !onAppeared {
        canvasRepresentingView = CanvasRepresentingView(isClear: $isClear)
        onAppeared = true
      }
    }
  }
#endif
  
  private var legacyBody: some View {
    ZStack {
      Color.neutral.ignoresSafeArea()
      drawContent
      
      if showErrorAlert {
        errorOverlay
      }
    }
    .onAppear {
      if !onAppeared {
        canvasRepresentingView = CanvasRepresentingView(isClear: $isClear)
        onAppeared = true
      }
    }
  }
  
  private var errorOverlay: some View {
    ZStack {
      Color.black.opacity(0.8)
      VStack(spacing: 10) {
        Image(systemName: .exclamationmarkWarninglightFill)
          .font(.title)
          .foregroundStyle(.white)
        Text(String.errorAlert)
          .font(.title2)
          .bold()
          .multilineTextAlignment(.center)
          .foregroundStyle(.white)
      }
      .padding(30)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .foregroundStyle(.gray)
      )
    }
  }
  
  private var drawContent: some View {
    ZStack {
      Color.neutral.ignoresSafeArea()
      Group {
        if orientation.orientation == .portrait {
          contentsInVStack
        } else {
          contentsInHStack
        }
      }
    }
  }
  
  private var contentsInHStack: some View {
    VStack {
      Spacer()
      HStack {
#if DEBUG
        canvasView
          .padding(.leading, defaultPadding)
          .frame(maxWidth: 1000, maxHeight: 1000)
#elseif RELEASE
        canvasView
          .padding(.leading, defaultPadding)
          .frame(maxWidth: 500, maxHeight: 500)
#endif
        resultView
          .padding(.trailing, defaultPadding)
          .frame(maxWidth: 500, maxHeight: 500)
      }
      .padding(.vertical, defaultPadding)
      Spacer()
    }
  }
  
  private var contentsInVStack: some View {
    VStack {
#if DEBUG
      canvasView
        .padding(.top, defaultPadding)
        .frame(maxWidth: 1000, maxHeight: 1000)
#elseif RELEASE
      canvasView
        .padding(.top, defaultPadding)
        .frame(maxWidth: 500, maxHeight: 500)
#endif
      resultView
        .padding(.bottom, defaultPadding)
        .frame(maxWidth: 500, maxHeight: 800)
    }
    .padding(.horizontal, defaultPadding)
  }
}

// MARK: - Tab Bar Appearance
private func configureTabBarAppearance() {
  let appearance = UITabBarAppearance()
  appearance.configureWithOpaqueBackground()
  appearance.backgroundColor = UIColor(Color.neutral)

  let normalAttributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white.withAlphaComponent(0.6)
  ]
  let selectedAttributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor(Color.accentColor)
  ]

  appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
  appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
  appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.accentColor)
  appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

  appearance.inlineLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
  appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
  appearance.inlineLayoutAppearance.selected.iconColor = UIColor(Color.accentColor)
  appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes

  appearance.compactInlineLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
  appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
  appearance.compactInlineLayoutAppearance.selected.iconColor = UIColor(Color.accentColor)
  appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes

  UITabBar.appearance().standardAppearance = appearance
  UITabBar.appearance().scrollEdgeAppearance = appearance
}

// MARK: - iOS 26+ Tab Wrapper
#if canImport(FoundationModels)
@available(iOS 26.0, *)
private struct DescribeTabWrapper<DrawContent: View, ErrorOverlay: View>: View {
  @Binding var searchMode: SearchMode
  let showErrorAlert: Bool
  @ViewBuilder let drawContent: () -> DrawContent
  @ViewBuilder let errorOverlay: () -> ErrorOverlay

  @StateObject private var nlSearchViewModel = NaturalLanguageSearchViewModel()
  @FocusState private var isSearchFocused: Bool

  var body: some View {
    ZStack {
      TabView(selection: $searchMode) {
        Tab(String.searchModeDraw, systemImage: "pencil.and.scribble", value: .draw) {
          drawContent()
        }
        Tab(String.searchModeBrowse, systemImage: "square.grid.2x2", value: .browse) {
          ZStack {
            Color.neutral.ignoresSafeArea()
            SFSymbolListView(keyword: "")
          }
        }
        Tab(String.settings, systemImage: "gearshape", value: .settings) {
          SettingsView()
        }
        Tab(value: .describe, role: .search) {
          NavigationStack {
            ZStack {
              Color.neutral.ignoresSafeArea()
              NaturalLanguageSearchView(viewModel: nlSearchViewModel)
            }
          }
          .searchable(text: $nlSearchViewModel.searchText, placement: .automatic, prompt: String.nlSearchPlaceholder)
          .searchFocused($isSearchFocused)
          .onSubmit(of: .search) { nlSearchViewModel.performSearch() }
          .onChange(of: nlSearchViewModel.searchText) {
            if nlSearchViewModel.searchText.isEmpty {
              nlSearchViewModel.resetState()
            }
          }
          .onChange(of: searchMode) {
            if searchMode == .describe {
              isSearchFocused = true
            }
          }
        }
      }

      if showErrorAlert {
        errorOverlay()
      }
    }
    .onAppear { configureTabBarAppearance() }
  }
}
#endif
