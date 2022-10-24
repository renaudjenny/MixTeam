import ComposableArchitecture
import SwiftUI

struct ScoreRow: View {
    let store: StoreOf<Score>
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack {
                viewStore.team.imageIdentifier.image
                    .resizable()
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: 24, maxHeight: 24)
                Text(viewStore.team.name)
                    .lineLimit(1)
                    .frame(maxWidth: 120, alignment: .leading)

                TextField(
                    "0",
                    value: viewStore.binding(\.$points),
                    format: .number.sign(strategy: .always(includingZero: false))
                )
                .frame(maxWidth: 70)

                Spacer()

                Text("\(viewStore.accumulatedPoints)")
                    .bold()
                    .frame(maxWidth: 50, alignment: .trailing)
            }
            .swipeActions {
                Button(role: .destructive) { viewStore.send(.remove, animation: .default) } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(viewStore.team.colorIdentifier.color.opacity(30/100))
            .textFieldStyle(.roundedBorder)
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
