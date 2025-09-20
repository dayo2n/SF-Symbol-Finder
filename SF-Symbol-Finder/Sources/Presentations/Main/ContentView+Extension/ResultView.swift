//
//  ResultView.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/4/24.
//

import SwiftUI

extension DrawingFinderView {
    var resultView: some View {
        NavigationView {
            ZStack {
                Color.neutral
                VStack {
                    Text(results.isEmpty ? String.waitingForResult : .guideOnUseResultList)
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                        .padding(5)
                        .padding(.bottom)
                    NavigationLink(
                        destination: SFSymbolListView(keyword: selectedLabel)
                            .navigationTitle(selectedLabel),
                        isActive: $isNavigate,
                        label: { EmptyView() }
                    )
                    ForEach(results, id: \.self) { result in
                        Button {
                            selectedLabel = result.label
                            isNavigate = true
                        } label : {
                            VStack(spacing: 2) {
                                let label = result.label.replacingOccurrences(of: "_", with: ".")
                                Text("\(label)")
                                    .font(.callout)
                                    .bold()
                                    .foregroundStyle(.white)
                                Text("\(String.confidence) **\(result.confidence)**%")
                                    .font(.callout)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    if results.isEmpty {
                        Spacer(minLength: 0)
                    }
                }
                .padding(10)
                .background(Color.neutral)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .border(.white)
    }
}
