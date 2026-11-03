import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            MapScreen()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            ChatScreen()
                .tabItem {
                    Label("Assistant", systemImage: "bubble.left.and.text.bubble.right")
                }
        }
    }
}
