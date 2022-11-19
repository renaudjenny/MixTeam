import SwiftUI

@available(*, deprecated)
private struct ForegroundColor: ViewModifier {
    let color: ColorIdentifier
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.foregroundColor(color.color(for: colorScheme))
    }
}

extension View {
    @available(*, deprecated)
    func foregroundColor(_ color: ColorIdentifier) -> some View {
        modifier(ForegroundColor(color: color))
    }
}
