import Combine
import Foundation

@MainActor
final class TranslationViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var translatedText = ""
    @Published var sourceLanguage = "en"
    @Published var targetLanguage = "es"
    @Published var history: [TranslationRecord] = []
    @Published var isLoading = false
    @Published var showingError = false
    @Published var errorMessage = ""

    let languages: [LanguageOption] = [
        .init(code: "en", name: "English"),
        .init(code: "es", name: "Spanish"),
        .init(code: "fr", name: "French"),
        .init(code: "it", name: "Italian"),
        .init(code: "de", name: "German"),
        .init(code: "pt", name: "Portuguese")
    ]

    var canTranslate: Bool {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !isLoading && !trimmed.isEmpty && sourceLanguage != targetLanguage
    }

    private let api: MyMemoryAPI
    private let store: TranslationHistoryStore

    init(api: MyMemoryAPI = MyMemoryAPI(), store: TranslationHistoryStore? = nil) {
        self.api = api
        if let store {
            self.store = store
        } else {
            #if canImport(FirebaseFirestore)
            self.store = FirestoreTranslationStore()
            #else
            self.store = LocalTranslationStore()
            #endif
        }

        Task {
            await loadHistory()
        }
    }

    func swapLanguages() {
        let currentSource = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = currentSource
    }

    func translate() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard sourceLanguage != targetLanguage else {
            setError(TranslationError.sameLanguageSelection)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await api.translate(text: trimmed, from: sourceLanguage, to: targetLanguage)
            translatedText = result

            let record = TranslationRecord(
                id: UUID(),
                sourceText: trimmed,
                translatedText: result,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                createdAt: Date()
            )

            try await store.save(record)
            history.insert(record, at: 0)
            inputText = ""
        } catch {
            setError(error)
        }
    }

    func clearHistory() async {
        do {
            try await store.clear()
            history = []
        } catch {
            setError(error)
        }
    }

    func dismissError() {
        showingError = false
    }

    private func loadHistory() async {
        do {
            history = try await store.load().sorted { $0.createdAt > $1.createdAt }
        } catch {
            setError(error)
        }
    }

    private func setError(_ error: Error) {
        errorMessage = error.localizedDescription
        showingError = true
    }
}
