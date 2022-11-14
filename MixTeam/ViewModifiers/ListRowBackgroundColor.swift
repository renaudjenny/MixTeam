import SwiftUI

private struct ListRowBackgroundColor: ViewModifier {
    let color: ColorIdentifier
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.listRowBackground(color.color(for: colorScheme))
    }
}

extension View {
    func listRowBackground(color: ColorIdentifier) -> some View {
        modifier(ListRowBackgroundColor(color: color))
    }
}
