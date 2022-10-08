import ComposableArchitecture
import SwiftUI

struct PlayerRow: View {
    let player: Player
    let isInFirstTeam: Bool
    let store: StoreOf<App>

    var body: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.editPlayer(player)) } label: {
                HStack {
                    player.imageIdentifier.image
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 60, height: 60)
                        .padding([.leading, .trailing])
                    Text(player.name)
                    Spacer()
                    PlayerRowButtons(
                        player: player,
                        isInFirstTeam: isInFirstTeam,
                        store: store
                    )
                }
                .foregroundColor(Color.white)
            }
            .padding(.bottom, 4)
        }
    }
}

private struct PlayerRowButtons: View {
    let player: Player
    let isInFirstTeam: Bool
    let store: StoreOf<App>

    var body: some View {
        WithViewStore(store) { viewStore in
            if isInFirstTeam {
                Button { viewStore.send(.deletePlayer(player)) } label: {
                    Image(systemName: "minus.circle.fill")
                }.padding(.trailing)
            } else {
                Button { viewStore.send(.moveBackPlayer(player)) } label: {
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
            PlayerRow(
                player: .test,
                isInFirstTeam: true,
                store: .preview
            )
            Color.white.frame(height: 20)
            PlayerRow(
                player: .test,
                isInFirstTeam: false,
                store: .preview
            )
        }.background(Color.red)
    }
}
#endif
