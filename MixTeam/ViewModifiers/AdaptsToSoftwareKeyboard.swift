import SwiftUI
import Combine

// See https://gist.github.com/scottmatthewman/722987c9ad40f852e2b6a185f390f88d
struct AdaptsToSoftwareKeyboard: ViewModifier {
    @State var currentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .onAppear(perform: subscribeToKeyboardEvents)
    }

    private func subscribeToKeyboardEvents() {
        NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillShowNotification
        )
            .compactMap { $0.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect }
            .map { $0.height }
            .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))

        NotificationCenter.Publisher(
            center: NotificationCenter.default,
            name: UIResponder.keyboardWillHideNotification
        )
            .compactMap { _ in CGFloat.zero }
            .subscribe(Subscribers.Assign(object: self, keyPath: \.currentHeight))
    }
}
