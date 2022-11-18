import ComposableArchitecture
import SwiftUI

struct EditPlayerView: View {
    let store: StoreOf<Player>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                playerNameField
                ImagePicker(selection: viewStore.binding(\.$image), type: .player)
            }
            .background(color: viewStore.color, ignoreSafeAreaEdges: .all)
        }
    }

    private var title: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.name)
                .font(.largeTitle)
                .padding()
        }
    }

    private var playerNameField: some View {
        WithViewStore(store) { viewStore in
            HStack {
                TextField("Edit", text: viewStore.binding(\.$name))
                    .font(.title)
                    .padding()
                    .background(color: viewStore.color)
                    .modifier(AddDashedCardStyle())
                    .padding(.leading)
                doneButton.padding(.trailing)
            }.padding(.top)
        }
    }

    private var doneButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.setEdit(isPresented: false)) } label: {
                Label("Done", systemImage: "checkmark")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
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
