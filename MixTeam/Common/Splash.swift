import SwiftUI

struct Splash: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let point1 = CGPoint(
            x: rect.minX + rect.maxX * 6/100,
            y: rect.minY + rect.maxY * 41/100
        )
        path.move(to: point1)

        let point2 = CGPoint(
            x: rect.minX + rect.maxX * 28/100,
            y: rect.minY + rect.maxY * 41/100
        )
        path.addCurve(
            to: point2,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 8/100,
                y: rect.minY + rect.maxY * 36/100
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 28/100,
                y: rect.minY + rect.maxY * 47/100
            )
        )

        let point3 = CGPoint(
            x: rect.minX + rect.maxX * 21/100,
            y: rect.minY + rect.maxY * 31/100
        )
        path.addCurve(
            to: point3,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 26/100,
                y: rect.minY + rect.maxY * 36/100
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 19/100,
                y: rect.minY + rect.maxY * 35/100
            )
        )
        return path
    }
}

struct Splash_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        @State private var width: CGFloat = .zero
        @State private var height: CGFloat = .zero

        var body: some View {
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        Splash().stroke()
                        Circle()
                            .stroke()
                            .scale(1/10)
                        Image("splash")
                        .resizable()
                        .opacity(1/2)
                    }
                    .frame(width: self.width, height: self.height)
                    .border(Color.red)
                    Spacer()
                    Slider(value: self.$width, in: 0...geometry.size.width)
                    Slider(value: self.$height, in: 0...geometry.size.height)
                }.onAppear {
                    self.width = geometry.size.width
                    self.height = geometry.size.height/2
                }
            }.padding()
        }
    }
}
