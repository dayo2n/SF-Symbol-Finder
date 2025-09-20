//
//  ContentView.swift
//  SFSymbolFinder
//
//  Created by 제나 on 2/5/24.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TabView {
                DrawingFinderView()
                    .tabItem {
                        Image(.imgFinderTabIcon)
                        Text("Finder")
                    }
                InformView()
                    .tabItem {
                        Image(systemName: .gearshape)
                        Text("Settings")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("SF Symbols Finder")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
