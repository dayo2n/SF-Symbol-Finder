//
//  Frame6View.swift
//  SFSymbolFinder
//
//  Created by 제나 on 2/5/24.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View {
    
    struct Result: Hashable {
        let label: String
        let confidence: Int
    }
    @State private var isClear = false
    @State private var canvasView: CanvasRepresentingView?
    @Environment(\.undoManager) var undoManager
    @State private var results = [Result]()
    @State private var isNavigate = false
    @State private var selectedLabel = ""
    @State private var showErrorAlert = false
    @State private var onAppeared = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 30) {
                    ZStack {
                        canvasView
                        HStack {
                            if let undoManager = undoManager {
                                VStack {
                                    HStack(spacing: 20) {
                                        Button {
                                            undoManager.undo()
                                        } label: {
                                            Image(systemName: "arrow.uturn.backward")
                                                .font(.title2)
                                                .bold()
                                        }
                                        .keyboardShortcut("z", modifiers: .command)
                                        .buttonStyle(BorderedButtonStyle())
                                        Button {
                                            undoManager.redo()
                                        } label: {
                                            Image(systemName: "arrow.uturn.forward")
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
                                .padding()
                                Button("CLEAR") {
                                    isClear.toggle()
                                }
                                .buttonStyle(BorderedButtonStyle())
                                Button("SEARCH") {
                                    if let canvasView = canvasView {
                                        let uiImage = canvasView.getRenderedImage()
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
                                .padding([.bottom, .trailing])
                            }
                        }
                    }
                    .frame(width: 700)
                    NavigationView {
                        ZStack {
                            Color.neutral
                            VStack {
                                Text("You can search with the keyword below\nPress the button to see if there's a symbol you're looking for")
                                    .multilineTextAlignment(.center)
                                    .font(.headline)
                                    .foregroundStyle(Color.primary100)
                                    .padding()
                                Spacer()
                                NavigationLink(
                                    destination: SFSymbolsView(keyword: selectedLabel)
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
                                            Text("confidence **\(result.confidence)**%")
                                                .font(.callout)
                                                .foregroundStyle(.white.opacity(0.8))
                                        }
                                        .frame(width: 350)
                                    }
                                    .padding(2)
                                    .buttonStyle(BorderedButtonStyle())
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.neutral)
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .frame(width: 450)
                }
                .frame(height: 500)
                .padding(20)
                .background(Color.primary100)
            }
            .padding(50)
            .onAppear {
                if !onAppeared {
                    canvasView = CanvasRepresentingView(isClear: $isClear)
                    onAppeared = true
                }
            }
            
            if showErrorAlert {
                Color.black
                    .opacity(0.8)
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.warninglight.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                    Text("An error occured.\nPlease run the app again.")
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
    }
    
    private func predict(image: CIImage) {
        guard let coreMLModel = try? SFSymbolClassifier(configuration: MLModelConfiguration()),
              let visionModel = try? VNCoreMLModel(for: coreMLModel.model) else {
            fatalError("Loading CoreML Model Failed")
        }
        // Vision을 이용해 이미치 처리를 요청
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            guard error == nil else {
                fatalError("Failed Request")
            }
            // 식별자의 이름을 확인하기 위해 VNClassificationObservation로 변환해준다.
            guard let classification = request.results as? [VNClassificationObservation] else {
                fatalError("Faild convert VNClassificationObservation")
            }
            // 머신러닝을 통한 결과값 프린트
            let sortedClassification = classification.sorted(by: { $0.confidence > $1.confidence })
            var count = 0
            self.results = []
            for result in sortedClassification {
                print(canvasView!.canvas.drawing)
                print(result)
                if count == 5 { break }
                let confidence = Int(result.confidence * 100)
                self.results.append(Result(
                    label: result.identifier,
                    confidence: confidence
                ))
                count += 1
            }
            self.results.sort(by: { $0.confidence > $1.confidence})
        }
        
        // 이미지를 받아와서 perform을 요청하여 분석한다. (Vision 프레임워크)
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}

struct SFSymbolsView: View {
    let keyword: String
    private var systemNames: [String] {
        let keyword = keyword.replacingOccurrences(of: "_", with: ".")
        return Constants.sfsymbols.filter({ $0.contains(keyword)})
    }
    @State private var showClipboardAlert = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            Color.neutral
            ScrollView {
                VStack {
                    Text("Click to copy the name to the clipboard")
                        .font(.headline)
                        .foregroundStyle(Color.primary100)
                    LazyVGrid(columns: [GridItem()]) {
                        ForEach(systemNames, id: \.self) { systemName in
                            ZStack {
                                Rectangle()
                                    .stroke(Color.primary100, lineWidth: 0.5)
                                    .background(Color.neutral)
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
                                showClipboardAlert = true
                            }
                        }
                    }
                }
                .padding()
                .padding(.top, 40)
            }
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text(keyword)
                            .foregroundStyle(Color.accentColor)
                            .font(.body)
                        Spacer()
                    }
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
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
            
            if showClipboardAlert {
                Color
                    .black
                    .opacity(0.7)
                    .ignoresSafeArea()
                HStack(spacing: 10) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.title3)
                        .foregroundStyle(.white)
                    Text("Copied to clipboard")
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