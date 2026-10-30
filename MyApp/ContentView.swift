import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranslationViewModel()
    @State private var showingClearHistoryAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Enter Text") {
                    TextField("Type a word, phrase, or sentence", text: $viewModel.inputText, axis: .vertical)
                        .lineLimit(2...6)

                    Picker("From", selection: $viewModel.sourceLanguage) {
                        ForEach(viewModel.languages) { language in
                            Text(language.name).tag(language.code)
                        }
                    }

                    Button {
                        viewModel.swapLanguages()
                    } label: {
                        Label("Swap Languages", systemImage: "arrow.up.arrow.down.circle")
                            .frame(maxWidth: .infinity)
                    }

                    Picker("To", selection: $viewModel.targetLanguage) {
                        ForEach(viewModel.languages) { language in
                            Text(language.name).tag(language.code)
                        }
                    }

                    if viewModel.sourceLanguage == viewModel.targetLanguage {
                        Text("Choose different source and target languages.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Button {
                        Task {
                            await viewModel.translate()
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(viewModel.isLoading ? "Translating..." : "Translate")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.canTranslate)
                }

                Section("Translation") {
                    if viewModel.translatedText.isEmpty {
                        Text("Translation appears here")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(viewModel.translatedText)
                    }
                }

                Section {
                    if viewModel.history.isEmpty {
                        Text("No translations yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.history) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.sourceText)
                                    .font(.subheadline)
                                Text(item.translatedText)
                                    .font(.headline)
                                Text("\(item.sourceLanguage.uppercased()) -> \(item.targetLanguage.uppercased())")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    HStack {
                        Text("History")
                        Spacer()
                        if !viewModel.history.isEmpty {
                            Button("Clear") {
                                showingClearHistoryAlert = true
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("TranslationMe")
            .alert("Clear translation history?", isPresented: $showingClearHistoryAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    Task {
                        await viewModel.clearHistory()
                    }
                }
            } message: {
                Text("This will remove all saved translations.")
            }
            .alert("Something went wrong", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

#Preview {
    ContentView()
}
