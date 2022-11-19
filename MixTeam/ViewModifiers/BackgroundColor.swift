import SwiftUI

@available(*, deprecated)
private struct BackgroundColor: ViewModifier {
    let color: ColorIdentifier
    let brightness: Double
    let ignoreSafeAreaEdges: Edge.Set
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(color.color(for: colorScheme), ignoresSafeAreaEdges: ignoreSafeAreaEdges)
            .brightness(colorScheme == .dark ? -brightness : brightness)
    }
}

extension View {
    @available(*, deprecated)
    func background(
        color: ColorIdentifier,
        brightness: Double = 0,
        ignoreSafeAreaEdges: Edge.Set = []
    ) -> some View {
        modifier(BackgroundColor(color: color, brightness: brightness, ignoreSafeAreaEdges: ignoreSafeAreaEdges))
    }
}
