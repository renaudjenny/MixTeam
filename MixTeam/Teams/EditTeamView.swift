import ComposableArchitecture
import SwiftUI

struct EditTeamView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    var store: StoreOf<Team>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                teamNameField
                if verticalSizeClass == .compact {
                    GeometryReader { geometry in
                        HStack {
                            ImagePicker(selection: viewStore.binding(\.$image), type: .team)
                                .frame(width: geometry.size.width * 3/4)
                            colorPicker
                                .frame(width: geometry.size.width * 1/4)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        colorPicker
                        ImagePicker(selection: viewStore.binding(\.$image), type: .team)
                        removeButton
                    }
                }
            }
            .backgroundAndForeground(color: viewStore.color)
            .animation(.easeInOut, value: viewStore.color)
            .confirmationDialog(
                store.scope(state: \.deleteConfirmationDialog),
                dismiss: .removeConfirmationDismissed
            )
        }
    }

    private var teamNameField: some View {
        WithViewStore(store) { viewStore in
            HStack {
                TextField("Edit", text: viewStore.binding(\.$name))
                    .font(.title)
                    .padding()
                    .backgroundAndForeground(color: viewStore.color)
                    .dashedCardStyle()
                    .padding(.leading)
                doneButton.padding(.trailing)
            }.padding(.top)
        }
    }

    private var doneButton: some View {
        WithViewStore(store.stateless) { viewStore in
            Button { viewStore.send(.setEdit(isPresented: false)) } label: {
                Label("Done", systemImage: "checkmark")
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
        }
    }

    private var colorPicker: some View {
        Group {
            if verticalSizeClass == .compact {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                    colors
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        colors
                    }
                }
            }
        }
        .padding()
        .backgroundAndForeground(color: .aluminium)
        .dashedCardStyle()
        .padding()
    }

    private var colors: some View {
        WithViewStore(store) { viewStore in
            ForEach(MTColor.allCases.filter({ $0 != .aluminium })) { color in
                Button { viewStore.send(.setColor(color)) } label: {
                    Color.clear
                        .frame(width: 50, height: 50)
                        .overlay(Splash(animatableData: viewStore.color == color ? 1 : 0).stroke(lineWidth: 2.5))
                        .backgroundAndForeground(color: color)
                        .clipShape(Splash(animatableData: viewStore.color == color ? 1 : 0))
                }
                .accessibility(label: Text("\(color.rawValue.capitalized) color"))
            }
        }
    }

    private var removeButton: some View {
        WithViewStore(store) { viewStore in
            Button(role: .destructive) { viewStore.send(.removeTapped) } label: {
                Label("Remove this team", systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.primary)
            .padding()
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
