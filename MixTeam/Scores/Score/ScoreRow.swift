import ComposableArchitecture
import SwiftUI

struct ScoreRow: View {
    let store: StoreOf<Score>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                Text(viewStore.team.name)
                    .frame(width: 150, alignment: .leading)
                Text("+\(viewStore.points)")
                Spacer()
                Text("\(viewStore.accumulatedPoints)")
                    .bold()
            }
        }
    }
}

#if DEBUG
struct ScoreRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ScoreRow(store: Store(initialState: .preview, reducer: Score()))
            ScoreRow(store: Store(initialState: .secondPreview, reducer: Score()))
        }
    }
}

extension Score.State {
    static var preview: Self {
        Score.State(team: .preview, points: 15, accumulatedPoints: 35)
    }
    static var secondPreview: Self {
        Score.State(team: .preview, points: 15, accumulatedPoints: 350)
    }
}
#endif
