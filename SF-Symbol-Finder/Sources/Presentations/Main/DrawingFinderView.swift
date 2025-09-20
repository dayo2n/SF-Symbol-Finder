//
//  DrawingFinderView.swift
//  SF-Symbol-Finder
//
//  Created by ZENA on 9/17/25.
//

import SwiftUI
import CoreML
import Vision

struct DrawingFinderView: View {
    @State var isClear = false
    @State var canvasRepresentingView: CanvasRepresentingView?
    @Environment(\.undoManager) var undoManager
    @State var results = [Result]()
    @State var isNavigate = false
    @State var selectedLabel = ""
    @State var showErrorAlert = false
    @State var onAppeared = false
    @EnvironmentObject var orientation: Orientation
    var defaultPadding: CGFloat {
        Constants.deviceModel == DeviceModel.iPad.rawValue ? 30 : 10
    }
    
    var body: some View {
        ZStack {
//            Color.neutral.ignoresSafeArea()
            if orientation.orientation == .portrait {
                contentsInVStack
            } else {
                contentsInHStack
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
