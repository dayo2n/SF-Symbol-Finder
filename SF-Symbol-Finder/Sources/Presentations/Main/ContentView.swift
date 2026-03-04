//
//  Frame6View.swift
//  SFSymbolFinder
//
//  Created by 제나 on 2/5/24.
//

import SwiftUI
import CoreML
import Vision

enum SearchMode: String, CaseIterable {
    case describe
    case draw

    var title: String {
        switch self {
        case .draw: return String.searchModeDraw
        case .describe: return String.searchModeDescribe
        }
    }
}

struct ContentView: View {
    @State var isClear = false
    @State var canvasRepresentingView: CanvasRepresentingView?
    @Environment(\.undoManager) var undoManager
    @State var results = [Result]()
    @State var isNavigate = false
    @State var selectedLabel = ""
    @State var showErrorAlert = false
    @State var onAppeared = false
    @State private var searchMode: SearchMode = .describe
    #if canImport(FoundationModels)
    @StateObject private var nlSearchViewModel = {
        if #available(iOS 26.0, *) {
            return NaturalLanguageSearchViewModel()
        } else {
            fatalError()
        }
    }()
    #endif
    @EnvironmentObject var orientation: Orientation
    var defaultPadding: CGFloat {
        Constants.deviceModel == DeviceModel.iPad.rawValue ? 30 : 10
    }

    var body: some View {
        ZStack {
            Color.neutral.ignoresSafeArea()
            VStack(spacing: 0) {
                searchModePicker
                if searchMode == .draw {
                    drawContent
                } else {
                    describeContent
                }
            }

            if showErrorAlert {
                Color.black
                    .opacity(0.8)
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
                .background (
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.gray)
                )
            }
        }
        .onAppear {
            if !onAppeared {
                canvasRepresentingView = CanvasRepresentingView(isClear: $isClear)
                onAppeared = true
            }
        }
    }

    @ViewBuilder
    private var searchModePicker: some View {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            Picker("", selection: $searchMode) {
                ForEach(SearchMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, defaultPadding)
            .padding(.top, 8)
        }
        #endif
    }

    private var drawContent: some View {
        Group {
            if orientation.orientation == .portrait {
                contentsInVStack
            } else {
                contentsInHStack
            }
        }
    }

    @ViewBuilder
    private var describeContent: some View {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            NaturalLanguageSearchView(viewModel: nlSearchViewModel)
        }
        #endif
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
