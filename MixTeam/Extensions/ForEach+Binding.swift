import SwiftUI

// See: https://www.swiftbysundell.com/articles/bindable-swiftui-list-elements/

extension ForEach where ID == Data.Element.ID,
                        Data.Element: Identifiable,
                        Content: View {
    init<T>(
        _ data: Binding<T>,
        @ViewBuilder content: @escaping (T.Index, Binding<T.Element>) -> Content
    ) where Data == IdentifiableIndices<T>, T: MutableCollection {
        self.init(data.wrappedValue.identifiableIndices) { index in
            content(
                index.rawValue,
                Binding(
                    get: { data.wrappedValue[index.rawValue] },
                    set: { data.wrappedValue[index.rawValue] = $0 }
                )
            )
        }
    }
}

struct IdentifiableIndices<Base: RandomAccessCollection>
where Base.Element: Identifiable {

    typealias Index = Base.Index

    struct Element: Identifiable {
        let id: Base.Element.ID
        let rawValue: Index
    }

    fileprivate var base: Base
}

extension IdentifiableIndices: RandomAccessCollection {
    var startIndex: Index { base.startIndex }
    var endIndex: Index { base.endIndex }

    subscript(position: Index) -> Element {
        Element(id: base[position].id, rawValue: position)
    }

    func index(before index: Index) -> Index {
        base.index(before: index)
    }

    func index(after index: Index) -> Index {
        base.index(after: index)
    }
}

extension RandomAccessCollection where Element: Identifiable {
    var identifiableIndices: IdentifiableIndices<Self> {
        IdentifiableIndices(base: self)
    }
}
