import SwiftUI

private struct BackgroundColor: ViewModifier {
    let color: ColorIdentifier
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.background(color.color(for: colorScheme))
    }
}

extension View {
    func background(color: ColorIdentifier) -> some View {
        modifier(BackgroundColor(color: color))
    }
}
