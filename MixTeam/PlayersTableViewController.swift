//
//  PlayersTableViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

let kPlayersTableViewCellIdentifier = "playersTableViewCellIdentifier"

class PlayersTableViewController: UITableViewController {
    var players: [Player] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.players = Player.players
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPlayersTableViewCellIdentifier, for: indexPath)

        let player = self.players[indexPath.row]
        cell.textLabel?.text = player.name
        cell.imageView?.image = player.image

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.players.remove(at: indexPath.row)
            Player.players.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
