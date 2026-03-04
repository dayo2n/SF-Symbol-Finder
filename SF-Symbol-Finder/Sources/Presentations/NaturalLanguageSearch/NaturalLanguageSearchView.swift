//
//  NaturalLanguageSearchView.swift
//  SF-Symbol-Finder
//
//  Created by ZENA on 2026/03/04.
//

#if canImport(FoundationModels)
import SwiftUI

@available(iOS 26.0, *)
final class NaturalLanguageSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [String] = []
    @Published var isSearching = false
    @Published var hasSearched = false

    private let service = FoundationModelService()

    func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }

        isSearching = true
        hasSearched = true
        searchResults = []

        Task {
            do {
                let results = try await service.searchSymbols(for: query)
                await MainActor.run {
                    self.searchResults = results
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                }
            }
        }
    }
}

@available(iOS 26.0, *)
struct NaturalLanguageSearchView: View {
    @ObservedObject var viewModel: NaturalLanguageSearchViewModel
    @State private var showClipboardAlert = false
    @State private var selectedSymbol: String?
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.neutral.ignoresSafeArea()

            VStack(spacing: 16) {
                searchBar
                resultContent
            }
            .padding()

            if showClipboardAlert {
                clipboardAlert
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                TextField("", text: $viewModel.searchText, prompt: Text(String.nlSearchPlaceholder).foregroundColor(.white.opacity(0.5)))
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .focused($isTextFieldFocused)
                    .submitLabel(.search)
                    .onSubmit { viewModel.performSearch() }
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        viewModel.searchResults = []
                        viewModel.hasSearched = false
                        isTextFieldFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )

            Button {
                isTextFieldFocused = false
                viewModel.performSearch()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .disabled(viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSearching)
            .opacity(viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        if viewModel.isSearching {
            Spacer()
            ProgressView()
                .tint(.white)
            Text(String.nlSearching)
                .foregroundStyle(.gray)
            Spacer()
        } else if viewModel.searchResults.isEmpty {
            Spacer()
            Text(viewModel.hasSearched ? String.nlNoResults : String.nlSearchGuide)
                .font(.body)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        } else {
            Text(String.guideOnClickToCopy)
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            HStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: [GridItem()]) {
                        ForEach(viewModel.searchResults, id: \.self) { symbolName in
                            ZStack {
                                Rectangle()
                                    .stroke(Color.accentColor, lineWidth: 0.5)
                                    .background(selectedSymbol == symbolName ? Color.accentColor.opacity(0.3) : Color.neutral)
                                HStack(spacing: 10) {
                                    Image(systemName: symbolName)
                                        .font(.largeTitle)
                                        .padding()
                                        .foregroundStyle(.white)
                                        .frame(width: 80)
                                    Text(symbolName)
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                            }
                            .onTapGesture {
                                UIPasteboard.general.string = symbolName
                                selectedSymbol = symbolName
                                showClipboardAlert = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                    selectedSymbol = nil
                                }
                            }
                        }
                    }
                    .padding(.trailing, 4)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    private var clipboardAlert: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
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
#endif
