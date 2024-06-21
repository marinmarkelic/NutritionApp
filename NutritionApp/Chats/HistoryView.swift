import SwiftUI

struct HistoryView: View {

    let conversations: [ConversationViewModel]
    let newConversation: () -> Void
    let switchConversation: (String) -> Void

    var body: some View {
        ScrollView {
            VStack {
                Text(Strings.newChat)
                    .color(emphasis: .high)
                    .onTapGesture(perform: newConversation)
                    .maxWidth()

                ForEach(conversations) { conversation in
                    HStack {
                        Text(conversation.lastMessage)
                            .color(emphasis: .high)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .maxWidth()
                            .onTapGesture {
                                switchConversation(conversation.id)
                            }
                    }
                }
            }
            .maxWidth()
        }
        .padding()
        .background(Color.background)
        .navigationTitle(Strings.history.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }

}
