import ComposableArchitecture
import ImagePicker
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
//                ImagePicker(selection: viewStore.binding(\.$image), type: .player, color: viewStore.color)
            }
            .backgroundAndForeground(color: viewStore.color)
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
