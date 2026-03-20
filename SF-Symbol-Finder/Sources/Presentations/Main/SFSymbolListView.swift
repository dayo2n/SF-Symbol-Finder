//
//  SFSymbolListView.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/4/24.
//

import SwiftUI

struct SFSymbolListView: View {
    let keyword: String
    @Binding var searchText: String
    @State private var selectedCategory: SymbolCategory = .all

    private var isBrowseMode: Bool { keyword.isEmpty }

    private var keywordReplaced: String {
        keyword.replacingOccurrences(of: "_", with: ".")
    }

    private static let categoryIndex: [SymbolCategory: Set<String>] = {
        SymbolCategory.buildIndex(symbols: Constants.sfsymbols)
    }()

    private var filteredSymbols: [String] {
        var symbols = Constants.sfsymbols

        if isBrowseMode {
            if selectedCategory != .all,
               let categorySymbols = Self.categoryIndex[selectedCategory] {
                symbols = symbols.filter { categorySymbols.contains($0) }
            }
            if !searchText.isEmpty {
                let query = searchText.lowercased()
                symbols = symbols.filter { $0.contains(query) }
            }
        } else {
            symbols = symbols.filter { $0.contains(keywordReplaced) }
        }

        return symbols
    }

    init(keyword: String, searchText: Binding<String> = .constant("")) {
        self.keyword = keyword
        self._searchText = searchText
    }

    @State private var showClipboardAlert = false
    @State private var selectedSymbol: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.neutral
            VStack(spacing: 0) {
                if isBrowseMode {
                    browseHeader
                }
                ScrollView {
                    VStack {
                        if !isBrowseMode {
                            Text(String.guideOnClickToCopy)
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                        }
                        if filteredSymbols.isEmpty {
                            emptyStateView
                        } else {
                            symbolGrid
                        }
                    }
                    .padding()
                    .padding(.top, isBrowseMode ? 8 : 40)
                }
            }

            if !keyword.isEmpty {
                keywordHeader
            }

            if showClipboardAlert {
                clipboardAlertOverlay
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Browse Header (Search Bar + Category Chips)

    private var browseHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                TextField(String.browseSearchPlaceholder, text: $searchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SymbolCategory.allCases, id: \.self) { category in
                        categoryChip(category)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color.neutral)
    }

    private func categoryChip(_ category: SymbolCategory) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: category.iconName)
                    .font(.caption2)
                Text(category.displayName)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.white.opacity(0.1))
            .foregroundStyle(isSelected ? .black : .white)
            .clipShape(Capsule())
        }
    }

    // MARK: - Symbol Grid

    private var symbolGrid: some View {
        LazyVGrid(columns: [GridItem()]) {
            ForEach(filteredSymbols, id: \.self) { systemName in
                ZStack {
                    Rectangle()
                        .stroke(Color.accentColor, lineWidth: 0.5)
                        .background(selectedSymbol == systemName ? Color.accentColor.opacity(0.3) : Color.neutral)
                    HStack(spacing: 10) {
                        Image(systemName: systemName)
                            .font(.largeTitle)
                            .padding()
                            .foregroundStyle(.white)
                            .frame(width: 80)
                        Text(systemName)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                .onTapGesture {
                    UIPasteboard.general.string = systemName
                    selectedSymbol = systemName
                    showClipboardAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        selectedSymbol = nil
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            Text(String.browseNoResults)
                .font(.body)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 80)
    }

    // MARK: - Keyword Header (Draw mode)

    private var keywordHeader: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Text(keywordReplaced)
                        .foregroundStyle(Color.accentColor)
                        .font(.body)
                    Spacer()
                }
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: .chevronBackward)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding()
                    Spacer()
                }
            }
            .background(Color.black.opacity(0.3))
            Spacer()
            Spacer()
        }
    }

    // MARK: - Clipboard Alert

    private var clipboardAlertOverlay: some View {
        ZStack {
            Color
                .black
                .opacity(0.7)
                .ignoresSafeArea()
            HStack(spacing: 10) {
                Image(systemName: .docOnClipboard)
                    .font(.title3)
                    .foregroundStyle(.white)
                Text(String.alertCopied)
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.gray.opacity(0.5))
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showClipboardAlert = false
                }
            }
        }
    }
}
