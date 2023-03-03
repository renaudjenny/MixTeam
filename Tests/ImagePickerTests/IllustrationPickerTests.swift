import Assets
import ComposableArchitecture
import ImagePicker
import XCTest

@MainActor
final class IllustrationPickerTests: XCTestCase {
    func testImageTapped() async {
        let store = TestStore(initialState: .preview, reducer: IllustrationPicker())
        let image: MTImage = .heroin
        await store.send(.imageTapped(image)) {
            $0.selectedImage = image
        }
    }
}
