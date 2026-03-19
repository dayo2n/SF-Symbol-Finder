//
//  NaturalLanguageSearchView.swift
//  SF-Symbol-Finder
//
//  Created by ZENA on 2026/03/04.
//

#if canImport(FoundationModels)
import SwiftUI

@available(iOS 26.0, *)
enum ThinkingPhase: Equatable {
    case idle
    case analyzing
    case searching
    case finding
    case done(count: Int)
    case noResults
}

@available(iOS 26.0, *)
final class NaturalLanguageSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [String] = []
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var modelStatus: ModelStatus?
    @Published var thinkingPhase: ThinkingPhase = .idle
    @Published var thinkingMessage: String = ""

    private let service = FoundationModelService()
    private var thinkingTask: Task<Void, Never>?

    func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }

        isSearching = true
        hasSearched = true
        searchResults = []
        modelStatus = nil
        startThinking(query: query)

        Task {
            do {
                let result = try await service.searchSymbols(for: query)
                await MainActor.run {
                    self.searchResults = result.symbols
                    self.modelStatus = result.usedFallback ? result.modelStatus : nil
                    self.isSearching = false
                    self.finishThinking(count: result.symbols.count)
                }
            } catch {
                await MainActor.run {
                    self.modelStatus = .modelError
                    self.isSearching = false
                    self.finishThinking(count: 0)
                }
            }
        }
    }

    private func startThinking(query: String) {
        thinkingTask?.cancel()
        thinkingPhase = .analyzing
        thinkingMessage = String.nlThinkingAnalyzing.localized(with: query)

        thinkingTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            thinkingPhase = .searching
            thinkingMessage = String.nlThinkingSearching

            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            thinkingPhase = .finding
            thinkingMessage = String.nlThinkingFinding
        }
    }

    private func finishThinking(count: Int) {
        thinkingTask?.cancel()
        thinkingTask = nil
        if count > 0 {
            thinkingPhase = .done(count: count)
            thinkingMessage = String.nlThinkingDone.localized(with: count)
        } else {
            thinkingPhase = .noResults
            thinkingMessage = String.nlThinkingNoResults
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
    private var thinkingMessageBox: some View {
        if viewModel.thinkingPhase != .idle {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "apple.intelligence")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                        .symbolEffect(.pulse, isActive: viewModel.isSearching)
                    Text("Apple Intelligence")
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentColor)
                }
                HStack(spacing: 4) {
                    Text(viewModel.thinkingMessage)
                        .font(.callout)
                        .foregroundStyle(Color.white.opacity(0.85))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: viewModel.thinkingMessage)
                    if viewModel.isSearching {
                        ThinkingIndicatorView()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 0.5)
                    )
            )
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity
            ))
        }
    }

    @ViewBuilder
    private var resultContent: some View {
        if viewModel.isSearching {
            thinkingMessageBox
            Spacer()
            ProgressView()
            Spacer()
        } else if viewModel.searchResults.isEmpty {
            if viewModel.hasSearched {
                thinkingMessageBox
            }
            if viewModel.modelStatus != nil {
                modelStatusBanner
            }
            Spacer()
            Text(viewModel.hasSearched ? String.nlNoResults : String.nlSearchGuide)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if !viewModel.hasSearched {
                Text(String.nlModelDisclaimer)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            Spacer()
        } else {
            thinkingMessageBox
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

@available(iOS 26.0, *)
private struct ThinkingIndicatorView: View {
    private static let symbols = ["·", "✢", "✳\u{FE0E}", "✶", "✦", "✧"]
    @State private var index = 0
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(Self.symbols[index])
            .font(.callout)
            .foregroundStyle(Color.accentColor)
            .contentTransition(.interpolate)
            .animation(.easeInOut(duration: 0.25), value: index)
            .onReceive(timer) { _ in
                index = (index + 1) % Self.symbols.count
            }
    }
}
#endif
