//
//  functions.swift
//  SF-Symbol-Finder
//
//  Created by 제나 on 3/4/24.
//

import SwiftUI
import CoreML
import Vision

extension DrawingFinderView {
    func predict(image: CIImage) {
//        guard let coreMLModel = try? SFSymbolClassifier(configuration: MLModelConfiguration()),
//              let visionModel = try? VNCoreMLModel(for: coreMLModel.model) else {
//            fatalError("Loading CoreML Model Failed")
//        }
//        // Vision을 이용해 이미치 처리를 요청
//        let request = VNCoreMLRequest(model: visionModel) { request, error in
//            guard error == nil else {
//                fatalError("Failed Request")
//            }
//            // 식별자의 이름을 확인하기 위해 VNClassificationObservation로 변환해준다.
//            guard let classification = request.results as? [VNClassificationObservation] else {
//                fatalError("Faild convert VNClassificationObservation")
//            }
//            // 머신러닝을 통한 결과값 프린트
//            let sortedClassification = classification.sorted(by: { $0.confidence > $1.confidence })
//            var count = 0
//            self.results = []
//            for result in sortedClassification {
//                print(canvasRepresentingView!.canvas.drawing)
//                print(result)
//                if count == 5 { break }
//                let confidence = Int(result.confidence * 100)
//                self.results.append(Result(
//                    label: result.identifier,
//                    confidence: confidence
//                ))
//                count += 1
//            }
//            self.results.sort(by: { $0.confidence > $1.confidence})
//        }
//        
//        // 이미지를 받아와서 perform을 요청하여 분석한다. (Vision 프레임워크)
//        let handler = VNImageRequestHandler(ciImage: image)
//        do {
//            try handler.perform([request])
//        } catch {
//            print(error)
//        }
    }
}
