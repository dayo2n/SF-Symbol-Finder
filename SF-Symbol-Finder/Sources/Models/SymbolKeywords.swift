//
//  SymbolKeywords.swift
//  SF-Symbol-Finder
//
//  Created by ZENA on 2026/03/04.
//

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct SymbolKeywords {
    /// SF Symbol 이름을 구성하는 영어 키워드 배열 (예: ["heart", "plus", "fill"])
    var keywords: [String]
}
#endif
