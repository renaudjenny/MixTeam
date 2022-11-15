import ComposableArchitecture
import SwiftUI

struct EditPlayerView: View {
    let store: StoreOf<Player>
    @Environment(\.presentationMode) var presentation

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                playerNameField
                ImagePicker(color: viewStore.color, selection: viewStore.binding(\.$image), type: .player)
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
                    .foregroundColor(Color.white)
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
        WithViewStore(store) { viewStore in
            Button(action: { presentation.wrappedValue.dismiss() }, label: {
                Image(systemName: "checkmark")
                    .foregroundColor(viewStore.color)
                    .padding()
                    .background(Splash2())
                    .foregroundColor(.white)
            }).accessibility(label: Text("Done"))
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
