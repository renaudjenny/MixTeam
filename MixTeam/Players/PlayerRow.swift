import ComposableArchitecture
import SwiftUI

struct PlayerRow: View {
    let store: StoreOf<Player>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.edit) } label: {
                HStack {
                    viewStore.image.image
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 60, height: 60)
                        .padding([.leading, .trailing])
                    Text(viewStore.name)
                    Spacer()
                    PlayerRowButtons(store: store)
                }
                .foregroundColor(Color.white)
            }
            .padding(.bottom, 4)
        }
    }
}

private struct PlayerRowButtons: View {
    let store: StoreOf<Player>

    var body: some View {
        WithViewStore(store) { viewStore in
            if true {
                Button { viewStore.send(.delete) } label: {
                    Image(systemName: "minus.circle.fill")
                }.padding(.trailing)
            } else {
                Button { viewStore.send(.moveBack) } label: {
                    Image(systemName: "gobackward")
                }.padding(.trailing)
            }
        }
    }
}

#if DEBUG
struct PlayerRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PlayerRow(store: .preview)
            Color.white.frame(height: 20)
            PlayerRow(store: .preview)
        }.background(Color.red)
    }
}

extension StoreOf<Player> {
    static var preview: StoreOf<Player> {
        Store(initialState: Player.State(id: UUID(), name: "Test", image: .girl), reducer: Player())
    }
}
#endif
