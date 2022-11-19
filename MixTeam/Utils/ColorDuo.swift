import SwiftUI

private struct ColorDuo {
    let foreground: Color
    let background: Color
}

enum MTColor: String, Codable, CaseIterable {
    case leather
    case strawberry
    case lilac
    case bluejeans
    case grass
    case duck
    case citrus
    case aluminium

    private var duo: ColorDuo {
        switch self {
        case .leather: return ColorDuo(
            foreground: Color(hue: 36/360, saturation: 73/100, lightness: 29/100),
            background: Color(hue: 48/360, saturation: 71/100, lightness: 75/100)
        )
        case .strawberry: return ColorDuo(
            foreground: Color(hue: 335/360, saturation: 62/100, lightness: 42/100),
            background: Color(hue: 333/360, saturation: 43/100, lightness: 88/100)
        )
        case .lilac: return ColorDuo(
            foreground: Color(hue: 274/360, saturation: 100/100, lightness: 28/100),
            background: Color(hue: 275/360, saturation: 47/100, lightness: 80/100)
        )
        case .bluejeans: return ColorDuo(
            foreground: Color(hue: 216/360, saturation: 100/100, lightness: 36/100),
            background: Color(hue: 213/360, saturation: 53/100, lightness: 81/100)
        )
        case .grass: return ColorDuo(
            foreground: Color(hue: 151/360, saturation: 100/100, lightness: 23/100),
            background: Color(hue: 143/360, saturation: 34/100, lightness: 75/100)
        )
        case .duck: return ColorDuo(
            foreground: Color(hue: 191/360, saturation: 100/100, lightness: 19/100),
            background: Color(hue: 190/360, saturation: 54/100, lightness: 74/100)
        )
        case .citrus: return ColorDuo(
            foreground: Color(hue: 15/360, saturation: 88/100, lightness: 45/100),
            background: Color(hue: 12/360, saturation: 98/100, lightness: 83/100)
        )
        case .aluminium: return ColorDuo(
            foreground: Color(hue: 237/360, saturation: 9/100, lightness: 47/100),
            background: Color(hue: 200/360, saturation: 4/100, lightness: 86/100)
        )
        }
    }

    func foregroundColor(scheme: ColorScheme) -> Color {
        scheme == .dark ? self.duo.background : self.duo.foreground
    }
    func backgroundColor(scheme: ColorScheme) -> Color {
        scheme == .dark ? self.duo.foreground : self.duo.background
    }
}

private extension Color {
    init(hue: Double, saturation: Double, lightness: Double, opacity: Double = 1) {
        let brightness = lightness + saturation * min(lightness, 1 - lightness)
        let saturation = brightness <= 0 ? 0 : 2 * (1 - lightness / brightness)
        self.init(hue: hue, saturation: saturation, brightness: brightness, opacity: opacity)
    }
}

private struct BackgroundAndForeground: ViewModifier {
    let color: MTColor
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .foregroundColor(color.foregroundColor(scheme: colorScheme))
            .background(color.backgroundColor(scheme: colorScheme))
            .listRowBackground(color.backgroundColor(scheme: colorScheme))
    }
}

extension View {
    func backgroundAndForeground(color: MTColor) -> some View {
        modifier(BackgroundAndForeground(color: color))
    }
}

#if DEBUG
struct Color_Previews: PreviewProvider {
    static var previews: some View {
        let colors: [[MTColor]] = MTColor.allCases .enumerated().reduce(
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
                            VStack {
                                Text("Lorem Ipsum")
                                    .font(.title)
                                Text("Smaller text")
                                Text(color.rawValue.capitalized)
                                    .bold()

                                Button { } label: {
                                    Label("Add a new Team", systemImage: "plus")
                                        .frame(maxWidth: .infinity, minHeight: 30)
                                }
                                .buttonStyle(DashedButtonStyle(color: color))
                                .padding([.bottom, .horizontal])
                            }
                            .frame(width: 180, height: 200)
                            .backgroundAndForeground(color: color)
                        }
                    }
                }
            }
        }
    }
}
#endif
