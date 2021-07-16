import SwiftUI

extension Binding where Value == Int {
    var string: Binding<String> {
        Binding<String>(
            get: { String(wrappedValue) },
            set: {
                guard $0 != "" else { return }
                wrappedValue = Int($0) ?? wrappedValue
            }
        )
    }
}
