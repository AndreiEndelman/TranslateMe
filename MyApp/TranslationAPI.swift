import Foundation

private struct MyMemoryResponse: Decodable {
    struct DataPayload: Decodable {
        let translatedText: String
    }

    let responseData: DataPayload
}

struct MyMemoryAPI {
    nonisolated init() {}

    nonisolated func translate(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        var components = URLComponents(string: "https://api.mymemory.translated.net/get")
        components?.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "langpair", value: "\(sourceLanguage)|\(targetLanguage)")
        ]

        guard let url = components?.url else {
            throw TranslationError.badURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw TranslationError.unexpectedResponse
        }

        let decoded = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
        return decoded.responseData.translatedText
    }
}
