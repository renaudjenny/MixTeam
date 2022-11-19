import SwiftUI

@available(*, deprecated)
struct Shadow: ViewModifier {
    static let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.25)
    var isApplied: Bool = true

    func body(content: Content) -> some View {
        content.background(
            Color.white.clipShape(RoundedRectangle(cornerRadius: 20)).shadow(
                color: Self.shadowColor,
                radius: radius, x: x, y: y
            )
        )
    }

    private var radius: CGFloat { isApplied ? 3 : 0 }
    private var x: CGFloat { isApplied ? -2 : 0 }
    private var y: CGFloat { isApplied ? 2 : 0 }
}
