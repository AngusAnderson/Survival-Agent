import SwiftUI

struct ChatScreen: View {
    var body: some View {
        ContentUnavailableView(
            "Assistant Unavailable",
            systemImage: "brain",
            description: Text("Assistant will appear here")
        )
    }
}
