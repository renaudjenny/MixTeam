import SwiftUI

private struct DashedCardStyle: ViewModifier {
    var isShadowApplied: Bool
    private let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.25)

    func body(content: Content) -> some View {
        content
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .background(
                Color.white.clipShape(RoundedRectangle(cornerRadius: 20)).shadow(
                    color: shadowColor,
                    radius: radius, x: x, y: y
                )
            )
    }

    private var overlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(style: .init(lineWidth: 2, dash: [5, 5], dashPhase: 3))
            .padding(5)
    }

    private var radius: CGFloat { isShadowApplied ? 3 : 0 }
    private var x: CGFloat { isShadowApplied ? -2 : 0 }
    private var y: CGFloat { isShadowApplied ? 2 : 0 }
}

@available(*, deprecated)
struct AddDashedCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.dashedCardStyle()
    }
}

extension View {
    func dashedCardStyle(isShadowApplied: Bool = true) -> some View {
        modifier(DashedCardStyle(isShadowApplied: isShadowApplied))
    }
}

struct AddDashedCardStyle_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .fill(Color.gray)
            .dashedCardStyle()
            .frame(width: 300, height: 300)
    }
}
