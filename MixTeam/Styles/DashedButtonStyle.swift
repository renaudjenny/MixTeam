import SwiftUI

struct DashedButtonStyle: ButtonStyle {
    @available(*, deprecated)
    let dprColor: ColorIdentifier?
    let color: MTColor?
    @Environment(\.colorScheme) private var colorScheme

    @available(*, deprecated)
    init(dprColor: ColorIdentifier) {
        self.dprColor = dprColor
        self.color = nil
    }

    init(color: MTColor) {
        self.color = color
        self.dprColor = nil
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(color?.foregroundColor(scheme: colorScheme) ?? .primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color?.backgroundColor(scheme: colorScheme) ?? dprColor?.color(for: colorScheme) ?? .gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: strokeStyle(isPressed: configuration.isPressed))
                        .padding(5)
                )
                .foregroundColor(color?.foregroundColor(scheme: colorScheme))
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

extension ButtonStyle where Self == DashedButtonStyle {
    static func dashed(color: MTColor) -> Self {
        DashedButtonStyle(color: color)
    }
}

struct MixTeamButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Button(action: action) {
                Text("Common Button Style (Aluminium)")
            }
            .buttonStyle(DashedButtonStyle(color: .aluminium))

            Button(action: action) {
                Text("Common Button Style (Duck)")
            }
            .buttonStyle(DashedButtonStyle(color: .duck))

            Button(action: action) {
                Text("Small")
            }
            .buttonStyle(DashedButtonStyle(color: .peach))

            Button(action: action) {
                Image(systemName: "moon")
                Text("With an icon")
            }
            .buttonStyle(DashedButtonStyle(color: .strawberry))

            Button(action: action) {
                Image(systemName: "cube.box")
                    .resizable()
                    .frame(width: 60, height: 60)
            }
            .buttonStyle(DashedButtonStyle(color: .leather))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundAndForeground(color: .aluminium)
    }

    private static let action = { }
}
