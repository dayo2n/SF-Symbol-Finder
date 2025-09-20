//
//  CanvasView.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/4/24.
//

import SwiftUI

extension DrawingFinderView {
    var canvasView: some View {
        ZStack {
            canvasRepresentingView
            HStack {
                if let undoManager = undoManager {
                    VStack {
                        HStack(spacing: 20) {
                            Button {
                                undoManager.undo()
                            } label: {
                                Image(systemName: .arrowUturnBackward)
                                    .font(.title2)
                                    .bold()
                            }
                            .keyboardShortcut("z", modifiers: .command)
                            .buttonStyle(BorderedButtonStyle())
                            Button {
                                undoManager.redo()
                            } label: {
                                Image(systemName: .arrowUturnForward)
                                    .font(.title2)
                                    .bold()
                            }
                            .keyboardShortcut("z", modifiers: [.command, .shift])
                            .buttonStyle(BorderedButtonStyle())
                        }
                        Spacer()
                    }
                    .padding()
                }
                Spacer()
                VStack {
                    Spacer()
                    Button(String.buttonClear) {
                        isClear.toggle()
                    }
                    .buttonStyle(BorderedButtonStyle())
                    Button(String.buttonSearch) {
                        if let canvasRepresentingView = canvasRepresentingView {
                            let uiImage = canvasRepresentingView.getRenderedImage()
                            if let ciImage = CIImage(image: uiImage) {
                                predict(image: ciImage)
                            } else {
                                self.showErrorAlert = true
                            }
                        } else {
                            self.showErrorAlert = true
                        }
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
                .padding([.bottom, .trailing])
            }
        }
        .border(.white)
    }
}
