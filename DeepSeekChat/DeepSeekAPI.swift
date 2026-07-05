import Foundation

final class DeepSeekAPI {
    static let shared = DeepSeekAPI()
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    private let session = URLSession(configuration: .default)

    private init() {}

    func chat(
        messages: [Message],
        apiKey: String,
        stream: Bool = true,
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: baseURL) else {
            onComplete(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let apiMessages = messages.map { msg -> [String: String] in
            ["role": msg.role == .user ? "user" : "assistant", "content": msg.content]
        }

        let body: [String: Any] = [
            "model": "deepseek-chat",
            "messages": apiMessages,
            "stream": stream
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        if stream {
            performStreamRequest(request, onToken: onToken, onComplete: onComplete)
        } else {
            performRequest(request, onComplete: onComplete)
        }
    }

    private func performRequest(
        _ request: URLRequest,
        onComplete: @escaping (Result<Void, Error>) -> Void
    ) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                onComplete(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                onComplete(.failure(APIError.invalidResponse))
                return
            }

            DispatchQueue.main.async {
                // 非流式：一次性返回全部内容作为 token
                onComplete(.success(()))
            }
        }.resume()
    }

    private func performStreamRequest(
        _ request: URLRequest,
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (Result<Void, Error>) -> Void
    ) {
        let delegate = StreamDelegate(onToken: onToken, onComplete: onComplete)
        let streamSession = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        streamSession.dataTask(with: request).resume()
    }
}

private final class StreamDelegate: NSObject, URLSessionDataDelegate {
    let onToken: (String) -> Void
    let onComplete: (Result<Void, Error>) -> Void
    private var buffer = ""

    init(onToken: @escaping (String) -> Void, onComplete: @escaping (Result<Void, Error>) -> Void) {
        self.onToken = onToken
        self.onComplete = onComplete
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return }
        buffer += text

        let lines = buffer.components(separatedBy: "\n")
        buffer = lines.last ?? ""

        for line in lines.dropLast() {
            guard line.hasPrefix("data: "),
                  let jsonStr = line.dropFirst(6).data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: jsonStr) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let delta = choices.first?["delta"] as? [String: Any],
                  let content = delta["content"] as? String else { continue }
            DispatchQueue.main.async { self.onToken(content) }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.onComplete(.failure(error))
            } else {
                self.onComplete(.success(()))
            }
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "无效的 API 地址"
        case .invalidResponse: return "API 返回格式异常"
        }
    }
}
