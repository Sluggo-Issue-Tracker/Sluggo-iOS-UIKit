//
//  TeamTableViewController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/3/21.
//

import UIKit

class TeamTableViewController: UITableViewController {
    var identity: AppIdentity!
    var completion: ((TeamRecord) -> Void)?
    private var maxNumber: Int = 0
    private var fetchingTeams: [TeamRecord] = []
    private var teams: [TeamRecord] = []
    private var isFetching  = false
    private var semaphore = DispatchSemaphore(value: 1)

    override func viewDidLoad() {
        self.configureRefreshControl()
        self.handleRefreshAction()
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }

    private func preselectRow() {
        if teams.count == 0 { return }

        for iter in 0...teams.count-1 {
            let team = teams[iter]
            let indexPath = IndexPath(row: iter, section: 0)
            if team == self.identity.team {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.completion?(self.teams[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SLGSidebarCell", for: indexPath) as UITableViewCell
        let team = self.teams[indexPath.row]
        cell.textLabel?.text = team.name
        cell.accessoryType = (team == self.identity.team) ? .checkmark : .none

        return cell
    }

    @objc func handleRefreshAction() {

        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()

            let onSuccess = { (teams: [TeamRecord]) -> Void in
                self.teams = teams
            }

            let after = { () -> Void in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                    self.preselectRow()
                }
                self.semaphore.signal()
            }

            let teamManager = TeamManager(identity: self.identity)
            unwindPagination(manager: teamManager,
                             startingPage: 1,
                             onSuccess: onSuccess,
                             onFailure: self.presentErrorFromMainThread,
                             after: after)
        }
    }
}
