import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            PlayersView().tabItem { playersItem }
            TeamsView().tabItem { teamsItem }
        }
    }

    var playersItem: some View {
        VStack {
            Image(systemName: "person")
            Text("Players")
        }
    }

    var teamsItem: some View {
        VStack {
            Image(systemName: "person.3")
            Text("Teams")
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
