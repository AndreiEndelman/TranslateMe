import Foundation

struct LanguageOption: Identifiable, Hashable {
    let code: String
    let name: String

    var id: String { code }
}

struct TranslationRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let sourceText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let createdAt: Date
}

enum TranslationError: LocalizedError {
    case badURL
    case unexpectedResponse
    case sameLanguageSelection

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Unable to build translation request."
        case .unexpectedResponse:
            return "Received an unexpected response from the translation service."
        case .sameLanguageSelection:
            return "Source and target languages must be different."
        }
    }
}
