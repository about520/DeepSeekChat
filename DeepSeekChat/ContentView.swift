import SwiftUI

struct ContentView: View {
    @EnvironmentObject var chatStore: ChatStore
    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if !chatStore.isAPIKeySet {
                apiKeyPrompt
            } else {
                messageList
                inputBar
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var apiKeyPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            Text("设置 API Key")
                .font(.title2).fontWeight(.semibold)
            Text("在「设置」标签页中输入 DeepSeek API Key 后即可开始对话")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(chatStore.messages) { msg in
                        MessageBubble(message: msg)
                            .id(msg.id)
                    }

                    if chatStore.isStreaming {
                        MessageBubble(
                            message: Message(role: .assistant, content: chatStore.streamingContent)
                        )
                        .id("streaming")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .onChange(of: chatStore.messages.count) { _ in
                scrollToBottom(proxy)
            }
            .onChange(of: chatStore.streamingContent) { _ in
                scrollToBottom(proxy)
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        if let last = chatStore.messages.last {
            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
        } else if chatStore.isStreaming {
            withAnimation { proxy.scrollTo("streaming", anchor: .bottom) }
        }
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("输入消息...", text: $inputText, axis: .vertical)
                .focused($isFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                .lineLimit(1...5)

            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || chatStore.isStreaming)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        chatStore.send(text)
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }
            Text(message.content)
                .font(.body)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.role == .user ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.role == .user ? .white : .primary)
                .clipShape(RoundedRectangle(
                    cornerRadius: 18,
                    style: .continuous
                ))
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = message.content
                    } label: {
                        Label("复制", systemImage: "doc.on.doc")
                    }
                }
            if message.role == .assistant { Spacer(minLength: 60) }
        }
    }
}
