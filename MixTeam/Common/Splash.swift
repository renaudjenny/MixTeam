import SwiftUI

struct Splash: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let point1 = CGPoint(
            x: rect.minX + rect.maxX * 140/1000,
            y: rect.minY + rect.maxY * 325/1000
        )
        path.move(to: point1)

        let point2 = CGPoint(
            x: rect.minX + rect.maxX * 200/1000,
            y: rect.minY + rect.maxY * 485/1000
        )
        path.addQuadCurve(
            to: point2,
            control: CGPoint(
                x: rect.minX + rect.maxX * 275/1000,
                y: rect.minY + rect.maxY * 435/1000
            )
        )

        let point3 = CGPoint(
            x: rect.minX + rect.maxX * 270/1000,
            y: rect.minY + rect.maxY * 560/1000
        )
        path.addQuadCurve(
            to: point3,
            control: CGPoint(
                x: rect.minX + rect.maxX * 120/1000,
                y: rect.minY + rect.maxY * 550/1000
            )
        )

        let point4 = CGPoint(
            x: rect.minX + rect.maxX * 300/1000,
            y: rect.minY + rect.maxY * 620/1000
        )
        path.addQuadCurve(
            to: point4,
            control: CGPoint(
                x: rect.minX + rect.maxX * 330/1000,
                y: rect.minY + rect.maxY * 570/1000
            )
        )

        let point5 = CGPoint(
            x: rect.minX + rect.maxX * 330/1000,
            y: rect.minY + rect.maxY * 660/1000
        )
        path.addQuadCurve(
            to: point5,
            control: CGPoint(
                x: rect.minX + rect.maxX * 275/1000,
                y: rect.minY + rect.maxY * 685/1000
            )
        )

        let point6 = CGPoint(
            x: rect.minX + rect.maxX * 450/1000,
            y: rect.minY + rect.maxY * 730/1000
        )
        path.addCurve(
            to: point6,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 400/1000,
                y: rect.minY + rect.maxY * 600/1000
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 475/1000,
                y: rect.minY + rect.maxY * 645/1000
            )
        )

        let point7 = CGPoint(
            x: rect.minX + rect.maxX * 435/1000,
            y: rect.minY + rect.maxY * 950/1000
        )
        path.addQuadCurve(
            to: point7,
            control: CGPoint(
                x: rect.minX + rect.maxX * 420/1000,
                y: rect.minY + rect.maxY * 860/1000
            )
        )

        let point8 = CGPoint(
            x: rect.minX + rect.maxX * 510/1000,
            y: rect.minY + rect.maxY * 930/1000
        )
        path.addCurve(
            to: point8,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 440/1000,
                y: rect.minY + rect.maxY * 1010/1000
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 500/1000,
                y: rect.minY + rect.maxY * 1000/1000
            )
        )

        let point9 = CGPoint(
            x: rect.minX + rect.maxX * 495/1000,
            y: rect.minY + rect.maxY * 690/1000
        )
        path.addQuadCurve(
            to: point9,
            control: CGPoint(
                x: rect.minX + rect.maxX * 515/1000,
                y: rect.minY + rect.maxY * 890/1000
            )
        )

        let point10 = CGPoint(
            x: rect.minX + rect.maxX * 570/1000,
            y: rect.minY + rect.maxY * 680/1000
        )
        path.addCurve(
            to: point10,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 490/1000,
                y: rect.minY + rect.maxY * 630/1000
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 570/1000,
                y: rect.minY + rect.maxY * 630/1000
            )
        )

        let point11 = CGPoint(
            x: rect.minX + rect.maxX * 560/1000,
            y: rect.minY + rect.maxY * 790/1000
        )
        path.addQuadCurve(
            to: point11,
            control: CGPoint(
                x: rect.minX + rect.maxX * 555/1000,
                y: rect.minY + rect.maxY * 770/1000
            )
        )

        let point12 = CGPoint(
            x: rect.minX + rect.maxX * 625/1000,
            y: rect.minY + rect.maxY * 780/1000
        )
        path.addCurve(
            to: point12,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 570/1000,
                y: rect.minY + rect.maxY * 840/1000
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 625/1000,
                y: rect.minY + rect.maxY * 840/1000
            )
        )

        let point13 = CGPoint(
            x: rect.minX + rect.maxX * 640/1000,
            y: rect.minY + rect.maxY * 580/1000
        )
        path.addCurve(
            to: point13,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 620/1000,
                y: rect.minY + rect.maxY * 650/1000
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 560/1000,
                y: rect.minY + rect.maxY * 610/1000
            )
        )

        let point14 = CGPoint(
            x: rect.minX + rect.maxX * 725/1000,
            y: rect.minY + rect.maxY * 600/1000
        )
        path.addQuadCurve(
            to: point14,
            control: CGPoint(
                x: rect.minX + rect.maxX * 680/1000,
                y: rect.minY + rect.maxY * 560/1000
            )
        )

        let point15 = CGPoint(
            x: rect.minX + rect.maxX * 740/1000,
            y: rect.minY + rect.maxY * 495/1000
        )
        path.addCurve(
            to: point15,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 695/1000,
                y: rect.minY + rect.maxY * 520/1000
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 705/1000,
                y: rect.minY + rect.maxY * 490/1000
            )
        )

        let point16 = CGPoint(
            x: rect.minX + rect.maxX * 780/1000,
            y: rect.minY + rect.maxY * 420/1000
        )
        path.addCurve(
            to: point16,
            control1: CGPoint(
                x: rect.minX + rect.maxX * 810/1000,
                y: rect.minY + rect.maxY * 505/1000
            ),
            control2: CGPoint(
                x: rect.minX + rect.maxX * 820/1000,
                y: rect.minY + rect.maxY * 455/1000
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
                        .opacity(1/4)
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
