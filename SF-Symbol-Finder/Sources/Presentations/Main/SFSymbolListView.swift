//
//  SFSymbolListView.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/4/24.
//

import SwiftUI

struct SFSymbolListView: View {
    let keyword: String
    private var keywordReplaced: String {
        keyword.replacingOccurrences(of: "_", with: ".")
    }
    private var systemNames: [String] {
        if keywordReplaced.isEmpty {
            return Constants.sfsymbols
        }
        return Constants.sfsymbols.filter({ $0.contains(keywordReplaced)})
    }
    @State private var showClipboardAlert = false
    @State private var selectedSymbol: String?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.neutral.ignoresSafeArea()
            ScrollView {
                VStack {
                    Text(String.guideOnClickToCopy)
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                    LazyVGrid(columns: [GridItem()]) {
                        ForEach(systemNames, id: \.self) { systemName in
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
                .padding()
                .padding(.top, 40)
            }
            if !keyword.isEmpty {
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
            
            if showClipboardAlert {
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
        .navigationBarHidden(true)
    }
}
