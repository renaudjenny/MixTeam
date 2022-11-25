import ComposableArchitecture
import SwiftUI

struct EditPlayerView: View {
    let store: StoreOf<Player>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    TextField("Edit", text: viewStore.binding(\.$name))
                        .font(.title)
                        .padding(12)
                        .backgroundAndForeground(color: viewStore.color)
                        .dashedCardStyle()
                        .padding()
                    ImagePicker(selection: viewStore.binding(\.$image), type: .player, color: viewStore.color)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { viewStore.send(.setEdit(isPresented: false)) } label: {
                            Label("Done", systemImage: "checkmark")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                .backgroundAndForeground(color: viewStore.color)
            }
            .backgroundAndForeground(color: viewStore.color)
        }
    }
}

#if DEBUG
struct EditPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        EditPlayerView(store: .preview)
    }
}
#endif
