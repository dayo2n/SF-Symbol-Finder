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
    @Published var modelStatus: ModelStatus?

    private let service = FoundationModelService()

    func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }

        isSearching = true
        hasSearched = true
        searchResults = []
        modelStatus = nil

        Task {
            do {
                let result = try await service.searchSymbols(for: query)
                await MainActor.run {
                    self.searchResults = result.symbols
                    self.modelStatus = result.usedFallback ? result.modelStatus : nil
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.modelStatus = .modelError
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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                resultContent
            }

            if showClipboardAlert {
                clipboardAlert
            }
        }
    }

    @ViewBuilder
    private var modelStatusBanner: some View {
        if let status = viewModel.modelStatus {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: status == .modelNotReady ? "arrow.down.circle" : "exclamationmark.triangle.fill")
                    .font(.body)
                    .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.7))
                Text(status.localizedMessage)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        if viewModel.isSearching {
            Spacer()
            ProgressView()
            Text(String.nlSearching)
                .foregroundStyle(.secondary)
            Spacer()
        } else if viewModel.searchResults.isEmpty {
            if viewModel.modelStatus != nil {
                modelStatusBanner
            }
            Spacer()
            Text(viewModel.hasSearched ? String.nlNoResults : String.nlSearchGuide)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        } else {
            modelStatusBanner

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.searchResults, id: \.self) { symbolName in
                        HStack(spacing: 14) {
                            Image(systemName: symbolName)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                            Text(symbolName)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(selectedSymbol == symbolName ? Color.accentColor.opacity(0.2) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIPasteboard.general.string = symbolName
                            selectedSymbol = symbolName
                            showClipboardAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                selectedSymbol = nil
                            }
                        }
                        Divider()
                            .padding(.leading, 68)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var clipboardAlert: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            HStack(spacing: 10) {
                Image(systemName: .docOnClipboard)
                    .font(.title3)
                Text(String.alertCopied)
                    .font(.title3)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showClipboardAlert = false
                }
            }
        }
    }
}
#endif
