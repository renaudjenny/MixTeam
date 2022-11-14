import SwiftUI

enum ColorIdentifier: String, Identifiable, CaseIterable, Codable {
    case yellow
    case orange
    case red
    case pink
    case purple
    case blue
    case green
    case gray

    @available(*, deprecated, message: "Use color(for:) instead")
    var color: Color {
        self.color(for: .light)
    }

    func color(for scheme: ColorScheme) -> Color {
        switch self {
        case .yellow:
            return scheme == .dark
            ? Color(red: 255/255, green: 190/255, blue: 53/255)
            : .yellow
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        case .purple: return .purple
        case .blue: return .blue
        case .green: return .green
        case .gray: return .gray
        }
    }

    var name: String {
        switch self {
        case .yellow: return "yellow"
        case .orange: return "orange"
        case .red: return "red"
        case .pink: return "pink"
        case .purple: return "purple"
        case .blue: return "blue"
        case .green: return "green"
        case .gray: return "gray"
        }
    }

    var id: Int { hashValue }
}

#if DEBUG
struct Colors_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            let colors: [[ColorIdentifier]] = ColorIdentifier.allCases.enumerated().reduce(
                into: [[], []]
            ) { result, next in
                if next.offset.isMultiple(of: 2) {
                    result[0].append(next.element)
                } else {
                    result[1].append(next.element)
                }
            }
            ScrollView {
                HStack {
                    ForEach(colors, id: \.hashValue) { colorColumn in
                        VStack {
                            ForEach(colorColumn, id: \.hashValue) { color in
                                preview(for: color)
                            }
                        }
                    }
                }
            }
        }

        private func preview(for color: ColorIdentifier) -> some View {
            VStack {
                Text("Lorem Ipsum")
                    .font(.title)
                Text("Smaller text")

                Button { } label: {
                    Label("Add a new Team", systemImage: "plus")
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                .buttonStyle(DashedButtonStyle(color: color))
                .padding()
            }
            .frame(width: 180, height: 200)
            .background(color: color)
        }
    }
}
#endif
