//
//  TeamsTableViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 27/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

private let kTeamsTableViewCellIdentifier = "teamsTableViewCellIdentifier"

class TeamsTableViewController: UITableViewController {
    var teams: [Team] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.teams = Team.teams
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTeamsTableViewCellIdentifier, for: indexPath)

        let team = self.teams[indexPath.row]
        cell.textLabel?.text = team.name
        cell.imageView?.image = team.image
        cell.backgroundColor = team.color.withAlphaComponent(0.10)
        cell.textLabel?.backgroundColor = UIColor.clear

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addTeamViewController = segue.destination as? AddTeamViewController {
            addTeamViewController.addTeamAction = { (team: Team) in
                self.teams.append(team)
                self.tableView.reloadData()
            }
        }
    }

}
