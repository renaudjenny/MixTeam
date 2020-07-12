import SwiftUI

struct AddSoftRemoveButton: ViewModifier {
    let remove: () -> Void
    let isFirstTeam: Bool
    @State private var isRealRemoveButtonDisplayed = false

    func body(content: Content) -> some View {
        HStack {
            contentAndMinusButton(content).overlay(filterIfNeeded)
            if isRealRemoveButtonDisplayed {
                deleteButton.transition(.move(edge: .trailing))
            }
        }.animation(.default)
    }

    private func contentAndMinusButton(_ content: Content) -> some View {
        content.overlay(minusButton, alignment: .topTrailing)
    }

    private var minusButton: some View {
        VStack {
            if !isRealRemoveButtonDisplayed && !isFirstTeam {
                Button(action: displayRealRemoveButton) {
                    Image(systemName: "minus.circle")
                }
            }
        }
        .foregroundColor(.white)
        .padding()
    }

    private var deleteButton: some View {
        VStack(spacing: 20) {
            Button(action: remove) {
                VStack {
                    Text("Delete!")
                    Image(systemName: "minus.circle.fill")
                }
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(Color.red)
        .modifier(AddDashedCardStyle())
    }

    @ViewBuilder private var filterIfNeeded: some View {
        Button(action: hideRealRemoveButton) {
            Color.black
                .opacity(isRealRemoveButtonDisplayed ? 2/10 : 0)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }.allowsHitTesting(isRealRemoveButtonDisplayed)
    }

    private func displayRealRemoveButton() {
        isRealRemoveButtonDisplayed = true
    }

    private func hideRealRemoveButton() {
        isRealRemoveButtonDisplayed = false
    }
}
