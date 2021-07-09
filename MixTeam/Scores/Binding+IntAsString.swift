import SwiftUI

extension Binding where Value == Int {
    var string: Binding<String> {
        Binding<String>(
            get: { String(wrappedValue) },
            set: { wrappedValue = Int($0) ?? wrappedValue }
        )
    }
}
