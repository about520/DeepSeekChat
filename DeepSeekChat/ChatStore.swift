import Foundation
import Combine

final class ChatStore: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isStreaming = false
    @Published var streamingContent = ""
    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "deepseek_api_key") }
    }

    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "deepseek_api_key") ?? ""
    }

    var isAPIKeySet: Bool { !apiKey.trimmingCharacters(in: .whitespaces).isEmpty }

    func send(_ text: String) {
        let userMsg = Message(role: .user, content: text)
        messages.append(userMsg)

        isStreaming = true
        streamingContent = ""

        DeepSeekAPI.shared.chat(
            messages: messages,
            apiKey: apiKey,
            stream: true,
            onToken: { [weak self] token in
                self?.streamingContent += token
            },
            onComplete: { [weak self] result in
                DispatchQueue.main.async {
                    self?.isStreaming = false
                    switch result {
                    case .success:
                        let content = self?.streamingContent ?? ""
                        if !content.isEmpty {
                            self?.messages.append(Message(role: .assistant, content: content))
                        }
                        self?.streamingContent = ""
                    case .failure(let error):
                        self?.messages.append(Message(role: .assistant, content: "错误: \(error.localizedDescription)"))
                        self?.streamingContent = ""
                    }
                }
            }
        )
    }

    func clearChat() {
        messages.removeAll()
        streamingContent = ""
    }
}
