import SwiftUI

struct AddDashedCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: .init(lineWidth: 2, dash: [5, 5], dashPhase: 3))
                    .foregroundColor(Color.white)
                    .padding(5)
        )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: MainView.shadowColor,
                radius: 3, x: -2, y: 2
        )
    }
}
