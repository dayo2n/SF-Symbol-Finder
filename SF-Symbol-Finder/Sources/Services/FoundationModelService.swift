//
//  FoundationModelService.swift
//  SF-Symbol-Finder
//
//  Created by ZENA on 2026/03/04.
//

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
final class FoundationModelService {

    private let session: LanguageModelSession

    init() {
        let instructions = """
        You are an expert on Apple's SF Symbols and iOS/macOS UI design conventions. \
        Your job is to think about what the user is describing and return all the SF Symbol name \
        components that could match — including semantically related ones.

        SF Symbol names use dot-separated keywords like: "heart.fill", "arrow.up.circle", "tortoise.fill".

        IMPORTANT RULES:
        1. If the user enters keywords that look like SF Symbol name parts (e.g. "heart fill", "arrow up circle"), \
           include those exact words as keywords. They are directly searching by name.
        2. If the user describes something in natural language or describes a UI PURPOSE or USE CASE, \
           think about what SPECIFIC SF Symbol names would be relevant and which symbols are conventionally used \
           for that purpose in Apple's ecosystem and iOS apps.
        3. Expand the description into ALL related concrete symbol name keywords.

        UI purpose / use case examples:
        - "공유 버튼" or "share button" → ["square", "arrow", "up"] (square.and.arrow.up is the standard share icon)
        - "카테고리" or "category button" → ["square", "grid", "list", "rectangle", "sidebar", "tray"]
        - "설정" or "settings" → ["gear", "gearshape", "slider", "wrench", "switch"]
        - "홈" or "home" → ["house", "building"]
        - "검색" or "search" → ["magnifyingglass"]
        - "프로필" or "profile" → ["person", "circle", "crop"]
        - "더보기" or "more menu" → ["ellipsis", "line", "horizontal"]
        - "뒤로가기" or "back" → ["chevron", "backward", "left", "arrow"]
        - "닫기" or "close/dismiss" → ["xmark", "multiply"]
        - "즐겨찾기" or "favorite" → ["star", "heart", "bookmark"]
        - "다운로드" or "download" → ["arrow", "down", "square", "icloud"]
        - "삭제" or "delete" → ["trash", "xmark", "minus"]
        - "새로고침" or "refresh" → ["arrow", "clockwise", "counterclockwise"]
        - "알림" or "notification" → ["bell", "exclamationmark", "badge"]
        - "탭바" or "tab bar" → ["house", "magnifyingglass", "person", "gear", "star"]
        - "필터" or "filter" → ["line", "horizontal", "decrease", "slider"]
        - "정렬" or "sort" → ["arrow", "up", "down", "line"]

        Semantic / descriptive examples:
        - "동물" or "animal" → ["tortoise", "hare", "bird", "fish", "ant", "ladybug", "cat", "dog", "pawprint", "lizard", "rabbit", "bear", "dinosaur", "duck", "frog"]
        - "날씨" or "weather" → ["sun", "moon", "cloud", "rain", "snow", "bolt", "wind", "thermometer", "humidity", "tornado", "snowflake", "rainbow"]
        - "채워진 하트" or "filled heart" → ["heart", "fill"]
        - "경고" or "warning" → ["exclamationmark", "warning", "xmark", "nosign", "hand", "stop"]
        - "음악" or "music" → ["music", "note", "beats", "headphones", "speaker", "waveform", "pianokeys", "guitars", "metronome"]
        - "사람" or "people" → ["person", "figure", "people"]
        - "위쪽 화살표" → ["arrow", "up", "chevron"]
        - "통신" or "communication" → ["phone", "envelope", "message", "bubble", "video", "antenna", "wifi"]
        - "편집" or "editing" → ["pencil", "scissors", "wand", "crop", "slider", "paintbrush", "eraser", "lasso"]
        - "올가미" or "lasso" → ["lasso", "sparkles"]
        - "번역" or "translate" or "통역" → ["translate", "globe", "character", "textformat", "bubble"]
        - "언어" or "language" or "다국어" → ["globe", "translate", "character", "textformat", "abc"]

        The user may describe symbols in any language including Korean. Always return English keywords.
        Common Korean-English mappings: 올가미=lasso, 공유=share, 설정=settings/gear, 검색=search/magnifyingglass, \
        삭제=trash/delete, 즐겨찾기=star/bookmark, 알림=bell/notification, 카메라=camera, 사진=photo, \
        잠금=lock, 위치=location/map, 달력=calendar, 시계=clock, 폴더=folder, 파일=doc/document, \
        번역=translate, 통역=translate, 언어=globe/translate.
        Return as many relevant keywords as possible to maximize search coverage.
        """

        self.session = LanguageModelSession(instructions: instructions)
    }

    func searchSymbols(for description: String) async throws -> [String] {
        // Foundation Model로 키워드 추출 시도
        var keywords: [String] = []

        if SystemLanguageModel.default.isAvailable {
            do {
                let prompt = "What SF Symbol name keywords are related to this description? Think broadly about all symbols that could match: \"\(description)\""
                let response = try await session.respond(to: prompt, generating: SymbolKeywords.self)
                keywords = response.content.keywords.map { $0.lowercased() }
            } catch {
                // 모델 실패 시 폴백으로 진행
            }
        }

        // 모델 미사용/실패 시 직접 키워드 분리
        if keywords.isEmpty {
            keywords = description
                .lowercased()
                .split(separator: " ")
                .map(String.init)
        }

        var matchedSymbols = matchSymbols(with: keywords)

        // 추가 폴백: 키워드 부분 매칭이 안 되면 개별 글자 매칭
        if matchedSymbols.isEmpty {
            let singleChars = keywords.flatMap { $0.split(separator: ".").map(String.init) }
            matchedSymbols = matchSymbols(with: singleChars)
        }

        return matchedSymbols
    }

    private func matchSymbols(with keywords: [String]) -> [String] {
        guard !keywords.isEmpty else { return [] }

        let scored: [(name: String, score: Int)] = Constants.sfsymbols.compactMap { symbolName in
            let score = keywords.reduce(0) { count, keyword in
                symbolName.contains(keyword) ? count + 1 : count
            }
            return score > 0 ? (symbolName, score) : nil
        }

        return scored
            .sorted { $0.score > $1.score }
            .prefix(50)
            .map(\.name)
    }
}
#endif
