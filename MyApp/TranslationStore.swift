import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

protocol TranslationHistoryStore {
    func load() async throws -> [TranslationRecord]
    func save(_ record: TranslationRecord) async throws
    func clear() async throws
}

actor LocalTranslationStore: TranslationHistoryStore {
    private let key = "translation_history"

    func load() async throws -> [TranslationRecord] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        return try JSONDecoder().decode([TranslationRecord].self, from: data)
    }

    func save(_ record: TranslationRecord) async throws {
        var records = try await load()
        records.insert(record, at: 0)
        let data = try JSONEncoder().encode(records)
        UserDefaults.standard.set(data, forKey: key)
    }

    func clear() async throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

#if canImport(FirebaseFirestore)
actor FirestoreTranslationStore: TranslationHistoryStore {
    private let collection = Firestore.firestore().collection("translations")

    func load() async throws -> [TranslationRecord] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { doc in
            guard
                let idString = doc["id"] as? String,
                let id = UUID(uuidString: idString),
                let sourceText = doc["sourceText"] as? String,
                let translatedText = doc["translatedText"] as? String,
                let sourceLanguage = doc["sourceLanguage"] as? String,
                let targetLanguage = doc["targetLanguage"] as? String,
                let createdAtInterval = doc["createdAt"] as? TimeInterval
            else {
                return nil
            }

            return TranslationRecord(
                id: id,
                sourceText: sourceText,
                translatedText: translatedText,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                createdAt: Date(timeIntervalSince1970: createdAtInterval)
            )
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ record: TranslationRecord) async throws {
        let payload: [String: Any] = [
            "id": record.id.uuidString,
            "sourceText": record.sourceText,
            "translatedText": record.translatedText,
            "sourceLanguage": record.sourceLanguage,
            "targetLanguage": record.targetLanguage,
            "createdAt": record.createdAt.timeIntervalSince1970
        ]

        try await setDocument(id: record.id.uuidString, payload: payload)
    }

    func clear() async throws {
        let snapshot = try await getDocuments()
        let batch = Firestore.firestore().batch()
        for document in snapshot.documents {
            batch.deleteDocument(document.reference)
        }
        try await commit(batch: batch)
    }

    private func getDocuments() async throws -> QuerySnapshot {
        try await withCheckedThrowingContinuation { continuation in
            collection.getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let snapshot else {
                    continuation.resume(throwing: TranslationError.unexpectedResponse)
                    return
                }

                continuation.resume(returning: snapshot)
            }
        }
    }

    private func setDocument(id: String, payload: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            collection.document(id).setData(payload) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func commit(batch: WriteBatch) async throws {
        try await withCheckedThrowingContinuation { continuation in
            batch.commit { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
#endif
