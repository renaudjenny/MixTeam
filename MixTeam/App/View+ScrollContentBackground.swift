import SwiftUI

private struct ScrollContentBackground: ViewModifier {
    let visibility: Visibility

    init(visibility: Visibility) {
        self.visibility = visibility
        if #unavailable(iOS 16.0) {
            UITableView.appearance().backgroundColor = .clear
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(visibility)
        } else {
            content
        }
    }
}

extension View {
    func scrollContentBackgroundLegacy(_ visibility: Visibility) -> some View {
        modifier(ScrollContentBackground(visibility: visibility))
    }
}

private struct ToolbarBackground: ViewModifier {
    let color: Color

    init(color: Color) {
        self.color = color
        if #unavailable(iOS 16.0) {
            UINavigationBar.appearance().barTintColor = UIColor(color)
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbarBackground(color, for: .navigationBar)
        } else {
            content
        }
    }
}

extension View {
    func toolbarBackgroundLegacy(color: Color) -> some View {
        modifier(ToolbarBackground(color: color))
    }
}
