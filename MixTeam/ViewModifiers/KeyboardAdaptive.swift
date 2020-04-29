import SwiftUI
import Combine

///https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/

struct KeyboardAdaptive: ViewModifier {
    @State private var bottomPadding: CGFloat = 0
    var extraPadding: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.bottomPadding)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    self.bottomPadding = self.bottomPadding(keyboardHeight: keyboardHeight, geometry: geometry)
            }.animation(.easeOut(duration: 0.16))
        }
    }

    private func bottomPadding(keyboardHeight: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
        let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
        // TODO: hardcoded value, it's really not ideal... let's see if we will keep tabBar at the end anyway
        let tabBarSize: CGFloat = 49.0
        return max(0, extraPadding + focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom + tabBarSize)
    }
}

extension View {
    func keyboardAdaptive(extraPadding: CGFloat = 0) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive(extraPadding: extraPadding))
    }
}

extension UIResponder {
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    private static weak var _currentFirstResponder: UIResponder?

    @objc private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }

    var globalFrame: CGRect? {
        guard let view = self as? UIView else { return nil }
        return view.superview?.convert(view.frame, to: nil)
    }
}
