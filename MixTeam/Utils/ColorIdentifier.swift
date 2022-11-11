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

    var color: Color {
        switch self {
        case .yellow: return .yellow
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
        let colors: [[Color]] = ColorIdentifier.allCases.enumerated().reduce(into: [[], []]) { result, next in
            if next.offset.isMultiple(of: 2) {
                result[0].append(next.element.color)
            } else {
                result[1].append(next.element.color)
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

    private static func preview(for color: Color) -> some View {
        VStack {
            Text("Lorem Ipsum")
                .font(.title)
            Text("Smaller text")
            
        }
        .frame(width: 180, height: 200)
        .background(color)
    }
}
#endif
