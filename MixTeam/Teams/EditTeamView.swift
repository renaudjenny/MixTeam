import ComposableArchitecture
import SwiftUI

struct EditTeamView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var store: StoreOf<Team>
    @State private var animateSplashGrowing: Bool = false
    @State private var animateSplashDripping: Bool = false

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                teamNameField
                if verticalSizeClass == .compact {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            ImagePicker(
                                color: viewStore.colorIdentifier,
                                selection: viewStore.binding(get: { $0.imageIdentifier }, send: { .imageUpdated($0) }),
                                type: .team
                            )
                            .frame(width: geometry.size.width * 3/4)
                            colorPicker
                                .frame(width: geometry.size.width * 1/4)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        colorPicker
                        ImagePicker(
                            color: viewStore.colorIdentifier,
                            selection: viewStore.binding(get: { $0.imageIdentifier }, send: { .imageUpdated($0) }),
                            type: .team
                        )
                    }
                }
            }
            .background(viewStore.colorIdentifier.color.edgesIgnoringSafeArea(.all))
            .task {
                withAnimation(.easeIn(duration: 0.4)) {
                    self.animateSplashGrowing = true
                }
                withAnimation(.easeInOut(duration: 2).delay(0.4)) {
                    self.animateSplashDripping = true
                }
            }
        }
    }

    private var teamNameField: some View {
        WithViewStore(store) { viewStore in
            HStack {
                TextField("Edit", text: viewStore.binding(get: { $0.name }, send: { .nameUpdated($0) }))
                    .foregroundColor(Color.white)
                    .font(.title)
                    .padding()
                    .background(viewStore.colorIdentifier.color)
                    .modifier(AddDashedCardStyle())
                    .padding(.leading)
                doneButton.padding(.trailing)
            }.padding(.top)
        }
    }

    private var doneButton: some View {
        WithViewStore(store.actionless) { viewStore in
            Button(action: { self.presentation.wrappedValue.dismiss() }, label: {
                Image(systemName: "checkmark")
                    .foregroundColor(viewStore.colorIdentifier.color)
                    .padding()
                    .background(Splash2())
                    .foregroundColor(.white)
            }).accessibility(label: Text("Done"))
        }
    }

    private var colorPicker: some View {
        WithViewStore(store.actionless) { viewStore in
            ScrollView(colorPickerScrollAxes, showsIndicators: false) {
                if verticalSizeClass == .compact {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                        colors
                    }
                } else {
                    HStack {
                        colors
                    }
                }
            }
            .padding()
            .background(viewStore.colorIdentifier.color.brightness(-0.2))
            .modifier(AddDashedCardStyle())
            .padding()
        }
    }

    private var colorPickerScrollAxes: Axis.Set {
        verticalSizeClass == .compact ? .vertical : .horizontal
    }

    private var colors: some View {
        WithViewStore(store.stateless) { viewStore in
            ForEach(ColorIdentifier.allCases) { colorIdentifier in
                Button(action: { viewStore.send(.colorUpdated(colorIdentifier)) }, label: {
                    colorIdentifier.color
                        .frame(width: 50, height: 50)
                        .clipShape(Splash(animatableData: self.animateSplashDripping ? 1 : 0))
                        .scaleEffect(self.animateSplashGrowing ? 1 : 0.1)
                }).accessibility(label: Text("\(colorIdentifier.name) color"))
            }
        }
    }
}

struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditTeamView(store: .preview)
            EditTeamView(store: .preview).previewLayout(.fixed(width: 800, height: 400))
        }
    }
}
