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
    }

    func saveDefaultTeamsIfNeeded() {
        if UserDefaults.standard.string(forKey: Team.teamsJSONStringKey) == nil {
            let teams = Team.loadListFromResource()
            Team.save(teams: teams)
        }
    }
}
