import SwiftUI

struct MixTeamButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Rectangle().fill(Color.red)
            .brightness(configuration.isPressed ? -1/4 : 0)
            .overlay(configuration.label.foregroundColor(.white))
    }
}
