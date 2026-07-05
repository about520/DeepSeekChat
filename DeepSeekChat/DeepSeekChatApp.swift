import SwiftUI

@main
struct DeepSeekChatApp: App {
    @StateObject private var chatStore = ChatStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    ContentView()
                        .environmentObject(chatStore)
                        .navigationTitle("DeepSeek AI")
                }
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("聊天")
                }

                NavigationStack {
                    BilibiliView()
                        .navigationTitle("哔哩哔哩")
                }
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("哔哩哔哩")
                }

                NavigationStack {
                    SettingsView()
                        .environmentObject(chatStore)
                        .navigationTitle("设置")
                }
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
            }
            .tint(.blue)
        }
    }
}
