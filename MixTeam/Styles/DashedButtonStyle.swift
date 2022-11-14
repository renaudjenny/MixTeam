import SwiftUI

struct DashedButtonStyle: ButtonStyle {
    let color: ColorIdentifier
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.color(for: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: strokeStyle(isPressed: configuration.isPressed))
                        .padding(5)
                )
                .modifier(Shadow(isApplied: !configuration.isPressed))
        )
    }

    func strokeStyle(isPressed: Bool) -> StrokeStyle {
        if isPressed {
            return StrokeStyle(
                lineWidth: 2,
                dash: [5, 5],
                dashPhase: 5
            )
        }
        return StrokeStyle(
            lineWidth: 2,
            dash: [5, 5],
            dashPhase: 3
        )
    }
}

struct MixTeamButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: action) {
                Text("Common Button Style (Red)")
            }
            .buttonStyle(DashedButtonStyle(color: .red))

            Button(action: action) {
                Text("Common Button Style (Green)")
            }
            .buttonStyle(DashedButtonStyle(color: .green))

            Button(action: action) {
                Text("Small")
            }
            .buttonStyle(DashedButtonStyle(color: .purple))

            Button(action: action) {
                Image(systemName: "moon")
                Text("With an icon")
            }
            .buttonStyle(DashedButtonStyle(color: .gray))

            Button(action: action) {
                Image(systemName: "cube.box")
                    .resizable()
                    .frame(width: 60, height: 60)
            }
            .buttonStyle(DashedButtonStyle(color: .gray))
        }
    }

    private static let action = { }
}
