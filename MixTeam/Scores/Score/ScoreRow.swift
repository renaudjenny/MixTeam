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
        guard let id = UUID(uuidString: "8A74A892-2C3F-4BB4-A8B3-19C5B1E0AD84") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        return Score.State(id: id, team: .preview, points: 15, accumulatedPoints: 35)
    }
    static var secondPreview: Self {
        guard let id = UUID(uuidString: "7C3E9E9F-31CE-462B-9894-08C699B13AD0") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        return Score.State(id: id, team: .preview, points: 15, accumulatedPoints: 350)
    }
}
#endif
