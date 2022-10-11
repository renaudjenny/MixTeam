import ComposableArchitecture
import SwiftUI

struct ScoreRow: View {
    let store: StoreOf<Score>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                HStack {
                    HStack {
                        Text(viewStore.team.name)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("+\(viewStore.points)")
                        Spacer()
                        Text("\(viewStore.accumulatedPoints)")
                            .bold()
                    }
                }
                .padding(12)
            }
        }
    }
}
