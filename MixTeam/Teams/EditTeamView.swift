import ComposableArchitecture
import SwiftUI

struct EditTeamView: View {
    let store: StoreOf<Team>
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                teamNameField
                if verticalSizeClass == .compact {
                    GeometryReader { geometry in
                        HStack {
                            ImagePicker(selection: viewStore.binding(\.$image), type: .team, color: viewStore.color)
                                .frame(width: geometry.size.width * 3/4)
                            colorPicker
                                .frame(width: geometry.size.width * 1/4)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        colorPicker
                        VStack(spacing: 0) {
                            Text("Choose a mascot")
                            ImagePicker(selection: viewStore.binding(\.$image), type: .team, color: viewStore.color)
                        }
                    }
                }
            }
            .backgroundAndForeground(color: viewStore.color)
            .animation(.easeInOut, value: viewStore.color)
        }
    }

    private var teamNameField: some View {
        WithViewStore(store) { viewStore in
            TextField("Edit", text: viewStore.binding(\.$name))
                .font(.title2.weight(.black))
                .multilineTextAlignment(.center)
                .dashedCardStyle(color: viewStore.color)
                .padding()
        }
    }

    private var colorPicker: some View {
        VStack {
            Text("Choose a colour")
            if verticalSizeClass == .compact {
                HStack {
                    VStack(spacing: 20) {
                        color(.peach)
                        color(.strawberry)
                        color(.lilac)
                    }
                    VStack(spacing: 20) {
                        color(.leather)
                        color(.conifer)
                        color(.duck)
                        color(.bluejeans)
                    }
                }
            } else {
                VStack {
                    HStack(spacing: 20) {
                        color(.leather)
                        color(.conifer)
                        color(.duck)
                        color(.bluejeans)
                    }
                    HStack(spacing: 20) {
                        color(.peach)
                        color(.strawberry)
                        color(.lilac)
                    }
                }
            }
        }
        .padding()
    }

    private func color(_ color: MTColor) -> some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.setColor(color)) } label: {
                Color.clear
                    .frame(width: 48, height: 48)
                    .overlay(Splash(animatableData: viewStore.color == color ? 1 : 0).stroke(lineWidth: 2.5))
                    .backgroundAndForeground(color: color)
                    .clipShape(Splash(animatableData: viewStore.color == color ? 1 : 0))
            }
            .accessibility(label: Text("\(color.rawValue)"))
        }
    }
}

#if DEBUG
struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditTeamView(store: .preview)
        }
    }
}
#endif
