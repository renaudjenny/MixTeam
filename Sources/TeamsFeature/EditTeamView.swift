import Assets
import ComposableArchitecture
import ImagePicker
import StyleCore
import SwiftUI

public struct EditTeamView: View {
    @Bindable var store: StoreOf<Team>
    #if os(iOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    public init(store: StoreOf<Team>) {
        self.store = store
    }

    #if os(iOS)
    public var body: some View {
        ScrollView {
            teamNameField
            if verticalSizeClass == .compact {
                GeometryReader { geometry in
                    HStack {
                        IllustrationPickerView(
                            store: store.scope(state: \.illustrationPicker, action: \.illustrationPicker)
                        )
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
                        IllustrationPickerView(
                            store: store.scope(state: \.illustrationPicker, action: \.illustrationPicker)
                        )
                    }
                }
            }
        }
        .backgroundAndForeground(color: store.color)
        .animation(.easeInOut, value: store.color)
        .navigationTitle("Editing \(store.name)")
    }
    #else
    public var body: some View {
        ScrollView {
            teamNameField
            VStack(spacing: 16) {
                colorPicker
                VStack(spacing: 0) {
                    Text("Choose a mascot")
                    IllustrationPickerView(
                        store: store.scope(state: \.illustrationPicker, action: \.illustrationPicker)
                    )
                }
            }
        }
        .backgroundAndForeground(color: store.color)
        .animation(.easeInOut, value: store.color)
    }
    #endif

    private var teamNameField: some View {
        TextField("Edit", text: $store.name)
            .font(.title2.weight(.black))
            .multilineTextAlignment(.center)
            .dashedCardStyle(color: store.color)
            .padding()
    }

    private var colorPicker: some View {
        VStack {
            Text("Choose a colour")
            #if os(iOS)
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
            #else
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
            #endif
        }
        .padding()
    }

    private func color(_ color: MTColor) -> some View {
        Button { store.send(.set(\.color, color)) } label: {
            Color.clear
                .frame(width: 48, height: 48)
                .overlay(Splash(animatableData: store.color == color ? 1 : 0).stroke(lineWidth: 2.5))
                .backgroundAndForeground(color: color)
                .clipShape(Splash(animatableData: store.color == color ? 1 : 0))
        }
        .accessibility(label: Text("\(color.rawValue)"))
    }
}

#if DEBUG
public extension Team.State {
    static var preview: Self {
        guard let id = UUID(uuidString: "EF9D6B84-B19A-4177-B5F7-6E2478FAAA18") else {
            fatalError("Cannot generate UUID from a defined UUID String")
        }
        return Team.State(
            id: id,
            name: "Team test",
            color: .strawberry,
            image: .koala
        )
    }
}

#Preview {
    NavigationView {
        EditTeamView(store: Store(initialState: .preview) { Team() })
    }
}
#endif
