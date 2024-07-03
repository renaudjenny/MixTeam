import ComposableArchitecture
import ImagePicker
import StyleCore
import SwiftUI

struct EditPlayerView: View {
    @Bindable var store: StoreOf<Player>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            TextField("Edit", text: $store.name.sending(\.nameChanged))
                .font(.title)
                .dashedCardStyle(color: store.color)
                .padding()
            IllustrationPickerView(
                store: store.scope(state: \.illustrationPicker, action: Player.Action.illustrationPicker)
            )
        }
        .backgroundAndForeground(color: store.color)
        .navigationTitle("Editing \(store.name)")
    }
}

#Preview {
    NavigationView {
        EditPlayerView(store: Store(initialState: .preview, reducer: { Player() }))
    }
}
