//
//  AppDelegate.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        self.saveDefaultTeamsIfNeeded()
        self.saveDefaultPlayersIfNeeded()
    }

    func saveDefaultTeamsIfNeeded() {
        if UserDefaults.standard.string(forKey: Team.teamsJSONStringKey) == nil
            || Team.loadList().count <= 0 {
            let teams = Team.loadListFromResource()
            Team.save(teams: teams)
        }
    }

    func saveDefaultPlayersIfNeeded() {
        if UserDefaults.standard.string(forKey: Player.playersJSONStringKey) == nil
            || Player.loadList().count <= 0 {
            let players = Player.loadListFromResource()
            Player.save(players: players)
        }
    }
}
