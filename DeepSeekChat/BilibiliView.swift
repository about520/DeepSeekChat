import SwiftUI
import WebKit

struct BilibiliView: View {
    @State private var urlString = "https://www.bilibili.com"
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // URL 导航栏
            HStack(spacing: 8) {
                TextField("输入哔哩哔哩链接...", text: $urlString)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .font(.subheadline)
                    .keyboardType(.URL)
                    .autocapitalization(.none)

                Button {
                    navigate()
                } label: {
                    Text("前往")
                        .font(.subheadline).fontWeight(.medium)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.98, green: 0.45, blue: 0.6))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial)

            // WebView
            ZStack {
                BilibiliWebView(
                    url: URL(string: urlString)!,
                    isLoading: $isLoading,
                    errorMessage: $errorMessage
                )

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                }

                if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemBackground))
    }

    private func navigate() {
        var url = urlString.trimmingCharacters(in: .whitespaces)
        if !url.hasPrefix("http") {
            url = "https://" + url
        }
        urlString = url
        errorMessage = nil
    }
}

struct BilibiliWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        let request = URLRequest(url: url)
        webView.load(request)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url?.absoluteString != url.absoluteString {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BilibiliWebView

        init(_ parent: BilibiliWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = "加载失败: \(error.localizedDescription)"
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = "无法连接: \(error.localizedDescription)"
        }
    }
}
