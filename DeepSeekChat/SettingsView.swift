import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var chatStore: ChatStore
    @State private var keyInput = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section {
                SecureField("sk-...", text: $keyInput)
                    .font(.system(.body, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onAppear { keyInput = chatStore.apiKey }

                Button("保存 API Key") {
                    let trimmed = keyInput.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else {
                        alertMessage = "请输入有效的 API Key"
                        showAlert = true
                        return
                    }
                    chatStore.apiKey = trimmed
                    alertMessage = "API Key 已保存"
                    showAlert = true
                }
                .frame(maxWidth: .infinity)
            } header: {
                Text("DeepSeek API Key")
            } footer: {
                Text("在 platform.deepseek.com 注册获取 API Key。Key 仅存储在本地，不会上传。")
            }

            Section {
                Button(role: .destructive) {
                    chatStore.clearChat()
                } label: {
                    HStack {
                        Spacer()
                        Text("清空对话记录")
                        Spacer()
                    }
                }
            }

            Section {
                Link(destination: URL(string: "https://platform.deepseek.com")!) {
                    Label("获取 API Key", systemImage: "arrow.up.forward.app")
                }
                Link(destination: URL(string: "https://www.bilibili.com")!) {
                    Label("打开哔哩哔哩", systemImage: "play.rectangle")
                }
            } header: {
                Text("相关链接")
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("确定", role: .cancel) {}
        }
    }
}
