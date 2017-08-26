//
//  PlayersTableViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class PlayersTableViewController: UITableViewController {
    static let playerTableViewCellIdentifier = "PlayersTableViewControllerPlayerTableViewCellIdentifier"
    static let teamHeaderViewIdentifier = "PlayersTableViewControllerTeamHeaderViewIdentifier"
    static let dispatchPlayerTime = DispatchTimeInterval.milliseconds(200)

    var autoSaveTimer: DispatchSourceTimer?
    var teams: [Team] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let firstTeam = Team(name: NSLocalizedString("Players standing for a team", comment: ""), color: UIColor.gray)
        self.teams.append(firstTeam)
        self.teams.append(contentsOf: Team.loadList())

        let nib = UINib(nibName: "TeamHeaderView", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: PlayersTableViewController.teamHeaderViewIdentifier)

        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.teams.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams[section].players.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.teams[section].name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlayersTableViewController.playerTableViewCellIdentifier, for: indexPath)

        let team = self.teams[indexPath.section]
        let player = team.players[indexPath.row]

        cell.textLabel?.text = player.name
        cell.imageView?.image = player.image?.tint(with: team.color)
        cell.backgroundColor = team.color.withAlphaComponent(0.10)
        cell.textLabel?.backgroundColor = UIColor.clear

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playerToDelete = self.teams[indexPath.section].players[indexPath.row]
            playerToDelete.delete()
            self.teams[indexPath.section].players.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0 else {
            // No need to customize "No team" section header
            return nil
        }

        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: PlayersTableViewController.teamHeaderViewIdentifier) as? TeamHeaderView

        headerCell?.titleLabel.text = self.teams[section].name
        headerCell?.logoImageView.image = self.teams[section].image
        headerCell?.view.backgroundColor = self.teams[section].color.withAlphaComponent(0.20)

        return headerCell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return tableView.rowHeight
        default:
            return 50.0
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.destination {
        case let viewController as EditPlayerViewController:
            if let selectedCell = sender as? UITableViewCell, let playerTableCellIndexPath = self.tableView.indexPath(for: selectedCell) {
                viewController.player = self.teams[playerTableCellIndexPath.section].players[playerTableCellIndexPath.row]
                viewController.editPlayerAction = { (player) in
                    self.tableView.reloadData()
                }
            }
        case let viewController as AddPlayerViewController:
            viewController.addPlayerAction = { (player: Player) in
                guard let firstTeam = self.teams.first else {
                    return
                }
                firstTeam.players.append(player)
                self.tableView.reloadData()
            }
        default: break
        }
    }

    @IBAction func mixTeam() {
        // TODO: check if there is more than 2 teams
        guard self.teams.count > 2 else {
            // TODO: Hint message
            return
        }

        guard let firstTeam = self.teams.first else {
            // TODO Throw error
            fatalError()
        }

        // First move all players back if needed
        for team in self.teams where team != self.teams.first {
            for player in team.players {
                self.move(player: player, from: team, to: firstTeam)
            }
        }

        // Dispatch players
        // To get animation effect, delay each move animation by kDispatchPlayerTime milliseconds
        var deadline: DispatchTime = .now()

        var teamHandicaps: [Team: Int] = [:]
        for team in teams where team != self.teams.first {
            teamHandicaps[team] = 0
            team.players.forEach {
                teamHandicaps[team]? += $0.handicap
            }
        }

        var playersTotalHandicap = 0
        self.teams.forEach { $0.players.forEach { playersTotalHandicap += $0.handicap }}

        for team in self.teams {
            for player in team.players {
                deadline = deadline + PlayersTableViewController.dispatchPlayerTime
                let toTeam = self.pseudoRandomTeam(teamHandicaps: teamHandicaps, playersTotalHandicap: playersTotalHandicap)
                teamHandicaps[team]? -= player.handicap
                teamHandicaps[toTeam]? += player.handicap
                if team != toTeam {
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        self.move(player: player, from: team, to: toTeam)
                    }
                }
            }
        }
    }

    func move(player: Player, from fromTeam: Team, to toTeam: Team) {
        guard let originPlayerIndex = fromTeam.players.index(where: { $0.id == player.id }),
            let originTeamSection = self.teams.index(where: { $0 == fromTeam }),
            let destinationTeamSection = self.teams.index(where: { $0 == toTeam }) else {
            return
        }
        let originIndexPath = IndexPath(row: originPlayerIndex, section: originTeamSection)
        let destinationIndexPath = IndexPath(row: toTeam.players.count, section: destinationTeamSection)

        toTeam.players.append(player)
        fromTeam.players.remove(at: originPlayerIndex)

        self.tableView.moveRow(at: originIndexPath, to: destinationIndexPath)
        self.tableView.reloadRows(at: [destinationIndexPath], with: .automatic)

        self.deferAutoSave()
    }

    func pseudoRandomTeam(teamHandicaps: [Team: Int], playersTotalHandicap: Int) -> Team {
        // First, add a player in each team if there is no one yet
        let teamsWithoutPlayers = teamHandicaps.filter({ $0.value <= 0 })
        if teamsWithoutPlayers.count > 0 {
            return teamsWithoutPlayers[Int(arc4random_uniform(UInt32(teamsWithoutPlayers.count)))].key
        }

        let handicapAverage = playersTotalHandicap / (self.teams.count - 1)

        // Choose only teams that total handicap is under the average
        var unbalancedTeams = teamHandicaps.filter({ $0.value < handicapAverage })

        return unbalancedTeams[Int(arc4random_uniform(UInt32(unbalancedTeams.count)))].key
    }

    func remove(team: Team) {
        guard let firstTeam = self.teams.first,
            let teamToDeleteIndex = self.teams.index(where: { $0 == team }) else {
            fatalError("Cannot retrieve first team or team to delete index")
        }

        let teamToDelete = self.teams[teamToDeleteIndex]

        teamToDelete.players.forEach { (player) in
            self.move(player: player, from: teamToDelete, to: firstTeam)
        }

        self.teams.remove(at: teamToDeleteIndex)
        self.tableView.reloadData()
    }
}

//NARK: - Auto Save

extension PlayersTableViewController {
    static let autoSaveDeferDelay = DispatchTimeInterval.seconds(2)

    func initAutoSaveTimer() {
        self.autoSaveTimer?.cancel()
        self.autoSaveTimer = DispatchSource.makeTimerSource()
        self.autoSaveTimer?.setEventHandler {
            let teamsToSave = Array(self.teams[1 ..< self.teams.count])
            Team.save(teams: teamsToSave)
        }
    }

    func deferAutoSave() {
        self.initAutoSaveTimer()

        let deadline: DispatchTime = .now() + PlayersTableViewController.autoSaveDeferDelay
        self.autoSaveTimer?.scheduleOneshot(deadline: deadline)
        self.autoSaveTimer?.resume()
    }
}

extension UIViewController {
    var playersTableViewController: PlayersTableViewController? {
        // Usefull filter to retrieve where is the PlayersTableViewController in the tab bar navigation
        let playerViewControllerFilter: (UIViewController) -> Bool = { (viewController) in
            return viewController.childViewControllers.first(where: { $0 is PlayersTableViewController }) is PlayersTableViewController
        }

        var navigationViewController: UIViewController? = nil
        if let playersNavigationViewController = self.tabBarController?.viewControllers?.first(where: playerViewControllerFilter) {
            // If self is presented in a navigation view controller
            navigationViewController = playersNavigationViewController
        }
        else if let tabBarController = self.presentingViewController as? UITabBarController,
            let playersNavigationViewController = tabBarController.viewControllers?.first(where: playerViewControllerFilter) {
            // If self is presented in a modal
            navigationViewController = playersNavigationViewController
        }

        guard let playersNavigationViewController = navigationViewController,
            let playersTableViewController = playersNavigationViewController.childViewControllers.first(where: { $0 is PlayersTableViewController }) as? PlayersTableViewController else {
            return nil
        }

        return playersTableViewController
    }
}
