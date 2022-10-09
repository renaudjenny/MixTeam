import ComposableArchitecture
import SwiftUI

struct EditPlayerView: View {
    let store: StoreOf<Player>
    @Environment(\.presentationMode) var presentation

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                playerNameField
                ImagePicker(
                    color: viewStore.color,
                    selection: viewStore.binding(get: { $0.image }, send: { .imageUpdated($0) }),
                    type: .player
                )
            }
            .background(viewStore.color.color.edgesIgnoringSafeArea(.all))
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
                TextField("Edit", text: viewStore.binding(get: { $0.name }, send: { .nameUpdated($0) }))
                    .foregroundColor(Color.white)
                    .font(.title)
                    .padding()
                    .background(viewStore.color.color)
                    .modifier(AddDashedCardStyle())
                    .padding(.leading)
                doneButton.padding(.trailing)
            }.padding(.top)
        }
    }

    private var doneButton: some View {
        WithViewStore(store) { viewStore in
            Button(action: { self.presentation.wrappedValue.dismiss() }, label: {
                Image(systemName: "checkmark")
                    .foregroundColor(viewStore.color.color)
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
