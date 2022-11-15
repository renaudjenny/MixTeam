import ComposableArchitecture
import SwiftUI

struct EditTeamView: View {
    @Environment(\.presentationMode) private var presentation
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    var store: StoreOf<Team>

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
                        removeButton
                    }
                }
            }
            .background(color: viewStore.colorIdentifier, ignoreSafeAreaEdges: .all)
            .confirmationDialog(
                store.scope(state: \.deleteConfirmationDialog),
                dismiss: .removeConfirmationDismissed
            )
        }
    }

    private var teamNameField: some View {
        WithViewStore(store) { viewStore in
            HStack {
                TextField("Edit", text: viewStore.binding(get: { $0.name }, send: { .nameUpdated($0) }))
                    .foregroundColor(Color.white)
                    .font(.title)
                    .padding()
                    .background(color: viewStore.colorIdentifier)
                    .modifier(AddDashedCardStyle())
                    .padding(.leading)
                doneButton.padding(.trailing)
            }.padding(.top)
        }
    }

    private var doneButton: some View {
        WithViewStore(store) { viewStore in
            Button(action: { self.presentation.wrappedValue.dismiss() }, label: {
                Image(systemName: "checkmark")
                    .foregroundColor(viewStore.colorIdentifier)
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
            .background(color: viewStore.colorIdentifier, brightness: -0.2)
            .modifier(AddDashedCardStyle())
            .padding()
        }
    }

    private var colorPickerScrollAxes: Axis.Set {
        verticalSizeClass == .compact ? .vertical : .horizontal
    }

    private var colors: some View {
        WithViewStore(store) { viewStore in
            ForEach(ColorIdentifier.allCases) { colorIdentifier in
                Button(action: { viewStore.send(.colorUpdated(colorIdentifier), animation: .easeInOut) }, label: {
                    colorIdentifier.color(for: colorScheme)
                        .frame(width: 50, height: 50)
                        .clipShape(Splash(animatableData: viewStore.colorIdentifier == colorIdentifier ? 1 : 0))
                })
                .accessibility(label: Text("\(colorIdentifier.name) color"))
            }
        }
    }

    private var removeButton: some View {
        WithViewStore(store) { viewStore in
            Button(role: .destructive) { viewStore.send(.removeTapped) } label: {
                Label("Remove this team", systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#if DEBUG
struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        EditTeamView(store: .preview)
    }
}
#endif
