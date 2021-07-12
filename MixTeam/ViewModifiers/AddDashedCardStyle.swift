import SwiftUI

struct AddDashedCardStyle: ViewModifier {

    func body(content: Content) -> some View {
        content
            .overlay(overlay)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .modifier(Shadow())
    }

    private var overlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(style: .init(lineWidth: 2, dash: [5, 5], dashPhase: 3))
            .foregroundColor(Color.white)
            .padding(5)
    }
}

struct AddDashedCardStyle_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle().modifier(AddDashedCardStyle())
            .frame(width: 300, height: 300)
    }
}
