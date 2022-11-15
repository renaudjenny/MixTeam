import SwiftUI

private struct ForegroundColor: ViewModifier {
    let color: ColorIdentifier
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.foregroundColor(color.color(for: colorScheme))
    }
}

extension View {
    func foregroundColor(_ color: ColorIdentifier) -> some View {
        modifier(ForegroundColor(color: color))
    }
}
