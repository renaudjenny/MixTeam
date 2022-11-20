import SwiftUI

// MARK: - Dashed Button Style

struct DashedButtonStyle: ButtonStyle {
    let color: MTColor
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundColor(color.foregroundColor(scheme: colorScheme))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.backgroundColor(scheme: colorScheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: strokeStyle(isPressed: configuration.isPressed))
                        .padding(5)
                )
                .foregroundColor(color.foregroundColor(scheme: colorScheme))
                .modifier(MTShadow(isApplied: !configuration.isPressed))
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

#if DEBUG
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
#endif

// MARK: - Dashed Card Style

private struct DashedCardStyle: ViewModifier {
    var isShadowApplied: Bool

    func body(content: Content) -> some View {
        content
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .modifier(MTShadow(isApplied: isShadowApplied))
    }

    private var overlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(style: .init(lineWidth: 2, dash: [5, 5], dashPhase: 3))
            .padding(5)
    }
}

extension View {
    func dashedCardStyle(isShadowApplied: Bool = true) -> some View {
        modifier(DashedCardStyle(isShadowApplied: isShadowApplied))
    }
}

#if DEBUG
struct DashedCardStyle_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(Color.gray)
            .dashedCardStyle()
            .frame(width: 300, height: 300)
    }
}
#endif

// MARK: MixTeam Shadow

private struct MTShadow: ViewModifier {
    var isApplied: Bool
    private let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.25)

    func body(content: Content) -> some View {
        content
            .background(
                Color.white.clipShape(RoundedRectangle(cornerRadius: 20)).shadow(
                    color: shadowColor,
                    radius: radius, x: x, y: y
                )
            )
    }

    private var radius: CGFloat { isApplied ? 3 : 0 }
    private var x: CGFloat { isApplied ? -2 : 0 }
    private var y: CGFloat { isApplied ? 2 : 0 }
}
