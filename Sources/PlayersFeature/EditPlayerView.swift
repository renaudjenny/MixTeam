import ComposableArchitecture
import ImagePicker
import StyleCore
import SwiftUI

struct EditPlayerView: View {
    let store: StoreOf<Player>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                TextField("Edit", text: viewStore.binding(\.$name))
                    .font(.title)
                    .dashedCardStyle(color: viewStore.color)
                    .padding()
                IllustrationPickerView(
                    store: store.scope(state: \.illustrationPicker, action: Player.Action.illustrationPicker)
                )
            }
            .backgroundAndForeground(color: viewStore.color)
            .navigationTitle("Editing \(viewStore.name)")
        }
    }
}

#if DEBUG
struct EditPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditPlayerView(store: .preview)
        }
    }
}
#endif
