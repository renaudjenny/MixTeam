import ComposableArchitecture
import SwiftUI

struct RoundRow: View {
    let store: StoreOf<Round>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEachStore(store.scope(state: \.scores, action: \.score)) { store in
                ScoreRow(store: store)
            }
        }
        .listRowInsets(EdgeInsets())
    }
}
