import SwiftUI

private struct ListRowBackgroundColor: ViewModifier {
    let color: ColorIdentifier
    private(set) var opacity: Double
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.listRowBackground(color.color(for: colorScheme).opacity(opacity))
    }
}

extension View {
    func listRowBackground(color: ColorIdentifier, opacity: Double = 1) -> some View {
        modifier(ListRowBackgroundColor(color: color, opacity: 1))
    }
}
